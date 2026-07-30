import 'dart:async';
import 'dart:isolate';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A helper class to manage isolates for executing background tasks.
class IsolateServices {
  /// Runs a function in a new isolate and returns the result.
  ///
  /// - [function]: The function to execute in the isolate.
  /// - [input]: Optional data passed to the function.
  /// - [timeout]: Specifies the maximum duration to wait for a result.
  /// - [onProgress]: A callback for progress updates from the isolate.
  /// - [cancelOnProgress]: A condition to cancel the operation based on progress updates.
  /// - [logger]: A callback for logging events during execution.
  static Future<T> run<T, U>({
    required Future<T> Function(U? input, SendPort? progressPort) function,
    U? input,
    Duration? timeout,
    void Function(dynamic progress)? onProgress,
    bool Function(dynamic progress)? cancelOnProgress,
    void Function(String log)? logger,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    final progressPort = ReceivePort();

    final rootToken = RootIsolateToken.instance!;

    // Spawn the isolate
    final isolate = await Isolate.spawn<_IsolateModel<T, U>>(
      _isolateEntry,
      _IsolateModel(
        token: rootToken,
        function: function,
        input: input,
        answerPort: receivePort.sendPort,
        errorPort: errorPort.sendPort,
        exitPort: exitPort.sendPort,
        progressPort: progressPort.sendPort,
      ),
    );

    final completer = Completer<T>();

    // Handle progress updates
    StreamSubscription<dynamic>? progressSubscription;
    if (onProgress != null || cancelOnProgress != null) {
      progressSubscription = progressPort.listen((progress) {
        logger?.call('Progress: $progress');
        if (cancelOnProgress?.call(progress) == true) {
          logger?.call('Cancelling isolate based on progress: $progress');
          _cleanup(
            isolate,
            receivePort,
            errorPort,
            exitPort,
            progressPort,
            progressSubscription,
          );
          if (!completer.isCompleted) {
            completer.completeError(
              IsolateHelperException(
                'Operation cancelled by progress condition.',
              ),
            );
          }
        } else {
          onProgress?.call(progress);
        }
      });
    }

    // Handle results
    receivePort.listen((result) {
      if (!completer.isCompleted) {
        logger?.call('Result received: $result');
        completer.complete(result as T);
      }
    });

    // Handle errors
    errorPort.listen((errorData) {
      if (!completer.isCompleted) {
        completer.completeError(
          IsolateHelperException(
            'Error in isolate',
            error: errorData['error'],
            stackTrace: errorData['stack'] != null
                ? StackTrace.fromString(errorData['stack'] as String)
                : StackTrace.current,
          ),
        );
      }
      _cleanup(
        isolate,
        receivePort,
        errorPort,
        exitPort,
        progressPort,
        progressSubscription,
      );
    });

    // Handle isolate exit
    exitPort.listen((_) {
      _cleanup(
        isolate,
        receivePort,
        errorPort,
        exitPort,
        progressPort,
        progressSubscription,
      );
    });

    // Await result with optional timeout
    try {
      return timeout != null ? await completer.future.timeout(timeout) : await completer.future;
    } catch (e) {
      _cleanup(
        isolate,
        receivePort,
        errorPort,
        exitPort,
        progressPort,
        progressSubscription,
      );
      rethrow;
    }
  }

  /// Cleans up resources used by the isolate.
  static void _cleanup(
    Isolate isolate,
    ReceivePort receivePort,
    ReceivePort errorPort,
    ReceivePort exitPort,
    ReceivePort progressPort, [
    StreamSubscription<dynamic>? progressSubscription,
  ]) {
    receivePort.close();
    errorPort.close();
    exitPort.close();
    progressPort.close();
    progressSubscription?.cancel();
    isolate.kill(priority: Isolate.immediate);
  }

  /// Entry point for the isolate.
  static Future<void> _isolateEntry<T, U>(
    _IsolateModel<T, U> isolateData,
  ) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);
    try {
      final result = await isolateData.function(
        isolateData.input,
        isolateData.progressPort,
      );
      isolateData.answerPort.send(result);
    } catch (e, s) {
      isolateData.errorPort?.send({
        'error': e.toString(),
        'stack': s.toString(),
      });
    } finally {
      isolateData.exitPort?.send(null);
    }
  }
}

/// Model for passing data to the isolate.
class _IsolateModel<T, U> extends Equatable {
  final RootIsolateToken token;
  final Future<T> Function(U? input, SendPort? progressPort) function;
  final U? input;
  final SendPort answerPort;
  final SendPort? errorPort;
  final SendPort? exitPort;
  final SendPort? progressPort;

  const _IsolateModel({
    required this.token,
    required this.function,
    this.input,
    required this.answerPort,
    this.errorPort,
    this.exitPort,
    this.progressPort,
  });

  @override
  List<Object?> get props => [
    token,
    function,
    input,
    answerPort,
    errorPort,
    exitPort,
    progressPort,
  ];
}

/// Custom exception class for isolate errors.
class IsolateHelperException implements Exception {
  final String message;
  final dynamic error;
  final StackTrace? stackTrace;

  IsolateHelperException(this.message, {this.error, this.stackTrace});

  @override
  String toString() {
    return 'IsolateHelperException: $message\n'
        'Error: $error\n'
        'StackTrace: ${stackTrace ?? 'Not available'}';
  }
}

void main() async {
  Future<int> computeSum(int? limit, SendPort? progressPort) async {
    int sum = 0;
    for (int i = 0; i <= limit!; i++) {
      sum += i;
      if (i % 5000 == 0) {
        progressPort?.send({
          'progress': i,
          'message': 'Processing up to $i...',
        });
        await Future.delayed(const Duration(milliseconds: 1));
      }
    }
    return sum;
  }

  try {
    final result = await IsolateServices.run<int, int>(
      function: computeSum,
      input: 50000,
      timeout: const Duration(seconds: 20),
      onProgress: (progress) {
        // Handle progress updates
        if (progress is Map) {
          if (kDebugMode) {
            print(
              'Progress: ${progress['progress']} - ${progress['message']}',
            );
          }
        }
      },
      cancelOnProgress: (progress) {
        // Cancel if progress exceeds a certain threshold
        if (progress is Map && progress['progress'] > 20000) {
          if (kDebugMode) {
            print(
              'Cancelling computation at progress: ${progress['progress']}',
            );
          }
          return true;
        }
        return false;
      },
      logger: (log) {
        if (kDebugMode) {
          print('LOG: $log');
        }
      },
    );

    // Print the final result
    if (kDebugMode) {
      print('Computation completed. The sum is: $result');
    }
  } catch (e) {
    // Handle any errors
    if (kDebugMode) {
      print('Error occurred: $e');
    }
  }
}
