import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager/photo_manager.dart';

import 'bloc/hq_picker_bloc.dart';
import 'bloc/hq_picker_event.dart';
import 'bloc/hq_picker_state.dart';
import 'tools/media_services.dart';
import 'widget/image_widget.dart';
import 'widget/video_widget.dart';

class HQPickerCustomPicker extends StatelessWidget {
  /// The maximum allowed number of selected items.
  final int maxCount;

  /// The type of request specifying what data is needed.
  final HQPickerRequestType requestType;

  /// Whether to show only videos in the picker.
  final bool showOnlyVideo;

  /// Whether to show only images in the picker.
  final bool showOnlyImage;

  /// The text displayed on the confirmation button.
  final String confirmText;

  /// The title text for the image tab in the tab bar.
  final String textTitleImageTabBar;

  /// The title text for the video tab in the tab bar.
  final String textTitleVideoTabBar;

  /// The text displayed when the list is empty.
  final String textEmptyList;

  /// The title widget displayed in the app bar.
  final Widget title;

  /// The text color of the confirmation button.
  final Color confirmTextColor;

  /// The color of the back button.
  final Color backBottomColor;

  /// The background color of the picker screen.
  final Color backgroundColor;

  /// The background color of the app bar.
  final Color backgroundAppBarColor;

  /// The background color of the tab bar.
  final Color backgroundTabBarColor;

  /// The color of the tab bar indicator.
  final Color indicatorColor;

  /// The text color when the list is empty.
  final Color textEmptyListColor;

  /// Constructor for the HQPickerCustomPicker class.
  const HQPickerCustomPicker({
    super.key,
    required this.maxCount,
    required this.requestType,
    this.showOnlyVideo = true,
    this.showOnlyImage = true,
    this.confirmText = 'Send',
    this.textTitleImageTabBar = 'Image',
    this.textTitleVideoTabBar = 'Video',
    this.textEmptyList = 'No albums found.',
    this.confirmTextColor = Colors.white,
    this.backBottomColor = Colors.white,
    this.backgroundColor = const Color.fromARGB(255, 206, 164, 236),
    this.backgroundAppBarColor = const Color.fromARGB(255, 206, 164, 236),
    this.backgroundTabBarColor = const Color(0xFF6A0DAD),
    this.indicatorColor = Colors.blue,
    this.textEmptyListColor = const Color(0xFF6A0DAD),
    this.title = const Text(
      'Album',
      style: TextStyle(fontSize: 22, color: Colors.white),
    ),
  });

  Future<List<AssetEntity>> getPicAssets(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => HQPickerBloc()..add(LoadAlbumsEvent(requestType: requestType)),
          child: HQPickerCustomPicker(
            maxCount: maxCount,
            requestType: requestType,
            showOnlyVideo: showOnlyVideo,
            showOnlyImage: showOnlyImage,
            confirmText: confirmText,
            textTitleImageTabBar: textTitleImageTabBar,
            textTitleVideoTabBar: textTitleVideoTabBar,
            textEmptyList: textEmptyList,
            confirmTextColor: confirmTextColor,
            backBottomColor: backBottomColor,
            backgroundColor: backgroundColor,
            backgroundAppBarColor: backgroundAppBarColor,
            backgroundTabBarColor: backgroundTabBarColor,
            indicatorColor: indicatorColor,
            textEmptyListColor: textEmptyListColor,
            title: title,
          ),
        ),
      ),
    );
    if (result != null && result is List<AssetEntity> && result.isNotEmpty) {
      return result;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return BlocBuilder<HQPickerBloc, HQPickerState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: backgroundColor,
              appBar: AppBar(
                backgroundColor: backgroundAppBarColor,
                title: title,
                centerTitle: true,
                leading: BackButton(
                  color: backBottomColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: InkResponse(
                      onTap: () {
                        if (state.selectedAssetList.isNotEmpty) {
                          Navigator.pop(context, state.selectedAssetList);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: backgroundTabBarColor,
                              margin: const EdgeInsets.all(15.0),
                              behavior: SnackBarBehavior.floating,
                              shape: BeveledRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              content: const Text('No image selected'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          color: confirmTextColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: SizedBox(
                  width: size.width,
                  height: size.height + 700,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: size.width,
                        height: 40,
                        color: backgroundTabBarColor,
                        child: TabBar(
                          indicatorWeight: 4,
                          labelColor: Colors.white,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorColor: indicatorColor,
                          unselectedLabelColor: Colors.white,
                          labelStyle: const TextStyle(fontSize: 18),
                          tabs: [
                            Text(textTitleImageTabBar),
                            Text(textTitleVideoTabBar),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (ScrollNotification scrollInfo) {
                              if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 200) {
                                context.read<HQPickerBloc>().add(LoadMoreAssetsEvent());
                              }
                              return false;
                            },
                            child: TabBarView(
                              children: [
                                HQPickerImageWidget(
                                  size: size,
                                  widget: this,
                                ),
                                HQPickerVideoWidget(
                                  size: size,
                                  widget: this,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
