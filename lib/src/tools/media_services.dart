import 'dart:async';

import 'package:photo_manager/photo_manager.dart';

enum HQPickerRequestType { common, audio, image, video, all }

RequestType _mapRequestType(HQPickerRequestType requestType) {
  switch (requestType) {
    case HQPickerRequestType.common:
      return RequestType.common;
    case HQPickerRequestType.audio:
      return RequestType.audio;
    case HQPickerRequestType.image:
      return RequestType.image;
    case HQPickerRequestType.video:
      return RequestType.video;
    default:
      return RequestType.all;
  }
}

class HQPickerMediaServices {
  static Future loadAlbums(HQPickerRequestType requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();

    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      final photoManagerRequestType = _mapRequestType(requestType);
      albumList = await PhotoManager.getAssetPathList(
        type: photoManagerRequestType,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  static Future loadAssets(AssetPathEntity selectedAlbum) async {
    int assetCount = await selectedAlbum.assetCountAsync;
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    return assetsList;
  }
}

class HQPickerMediaServices1 {
  Future loadAlbums(HQPickerRequestType requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      final photoManagerRequestType = _mapRequestType(requestType);
      albumList = await PhotoManager.getAssetPathList(
        type: photoManagerRequestType,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  Future<List<AssetEntity>> loadAssets(AssetPathEntity selectedAlbum) async {
    int assetCount = await selectedAlbum.assetCountAsync;
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    return assetsList;
  }
}

class HQPickerMediaServicesBottomSheet {
  Future<List<AssetPathEntity>> loadAlbums(
    HQPickerRequestType requestType,
  ) async {
    var permission = await PhotoManager.requestPermissionExtend();
    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      final photoManagerRequestType = _mapRequestType(requestType);
      albumList = await PhotoManager.getAssetPathList(
        type: photoManagerRequestType,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  Future<List<AssetEntity>> loadAssets(AssetPathEntity selectedAlbum) async {
    int assetCount = await selectedAlbum.assetCountAsync;
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    return assetsList;
  }
}

class HQPickerMediaServicesBottomSheetImageSelector {
  static Future loadAlbums(HQPickerRequestType requestType) async {
    var permission = await PhotoManager.requestPermissionExtend();

    List<AssetPathEntity> albumList = [];
    if (permission.isAuth == true) {
      final photoManagerRequestType = _mapRequestType(requestType);
      albumList = await PhotoManager.getAssetPathList(
        type: photoManagerRequestType,
      );
    } else {
      PhotoManager.openSetting();
    }
    return albumList;
  }

  static Future loadAssets(AssetPathEntity selectedAlbum) async {
    int assetCount = await selectedAlbum.assetCountAsync;
    List<AssetEntity> assetsList = await selectedAlbum.getAssetListRange(
      start: 0,
      end: assetCount,
    );
    return assetsList;
  }
}

///////////////////////////////////////////////////
///////////////////////////////////////////////////
///
///
///
///
///

///////////////////////////////////////////////////////
///
///
///
///
///
///
///
///
