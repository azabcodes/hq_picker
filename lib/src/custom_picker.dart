import 'package:flutter/material.dart';
import 'package:hq_picker/src/tools/media_services.dart';
import 'package:hq_picker/src/widget/image_widget.dart';
import 'package:hq_picker/src/widget/video_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class HQPickerCustomPicker extends StatefulWidget {
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
    this.confirmText = "Send",
    this.textTitleImageTabBar = "Image",
    this.textTitleVideoTabBar = "Video",
    this.textEmptyList = "No albums found.",
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

  @override
  State<HQPickerCustomPicker> createState() => _CustomPickerState();
  Future<List<AssetEntity>> getPicAssets(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HQPickerCustomPicker(
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
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      return result;
    }
    return [];
  }
}

class _CustomPickerState extends State<HQPickerCustomPicker>
    with AutomaticKeepAliveClientMixin {
  AssetEntity? selectedEntity;
  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity> albumList = [];
  List<AssetEntity> assetsList = [];
  List<AssetEntity> selectedAssetList = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLoading();
    _loadAlbum();
  }

  void _startLoading() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> _loadAlbum() async {
    HQPickerMediaServices.loadAlbums(widget.requestType)
        .then((value) {
          setState(() {
            if (value == null || value.isEmpty) {
              albumList = [];
            } else {
              albumList = value;
              selectedAlbum = value[0];

              HQPickerMediaServices.loadAssets(selectedAlbum!)
                  .then((value) {
                    setState(() {
                      if (value == null || value.isEmpty) {
                        selectedEntity = null;
                        assetsList = [];
                      } else {
                        selectedEntity = value[0];
                        assetsList = value;
                      }
                    });
                  })
                  .catchError((error) {
                    debugPrint("Error loading assets: $error");
                  });
            }
          });
        })
        .catchError((error) {
          debugPrint("Error loading albums: $error");
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: widget.backgroundColor,
          appBar: AppBar(
            backgroundColor: widget.backgroundAppBarColor,
            title: widget.title,
            centerTitle: true,
            leading: BackButton(
              color: widget.backBottomColor,
              onPressed: () {
                setState(() {
                  selectedAssetList.clear();
                  Navigator.pop(context);
                });
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkResponse(
                  onTap: () {
                    if (selectedAssetList.isNotEmpty) {
                      Navigator.pop(context, selectedAssetList);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: widget.backgroundTabBarColor,
                          margin: const EdgeInsets.all(15.0),
                          behavior: SnackBarBehavior.floating,
                          shape: BeveledRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          content: const Text("No image selected"),
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.confirmText,
                    style: TextStyle(
                      color: widget.confirmTextColor,
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
                    color: widget.backgroundTabBarColor,
                    child: TabBar(
                      indicatorWeight: 4,
                      labelColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: widget.indicatorColor,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(fontSize: 18),
                      tabs: [
                        Text(widget.textTitleImageTabBar),
                        Text(widget.textTitleVideoTabBar),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: TabBarView(
                        children: [
                          HQPickerImageWidget(
                            size: size,
                            widget: widget,
                            selectedAssetList: selectedAssetList,
                            assetsList: assetsList,
                            selectedEntity: selectedEntity,
                            loading: isLoading,
                          ),
                          HQPickerVideoWidget(
                            size: size,
                            widget: widget,
                            selectedAssetList: selectedAssetList,
                            assetsList: assetsList,
                            selectedEntity: selectedEntity,
                            loading: isLoading,
                          ),
                        ],
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
  }

  @override
  bool get wantKeepAlive => true;
}
