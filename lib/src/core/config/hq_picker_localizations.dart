/// Configurable localized texts across HQPicker.
class HQPickerLocalizations {
  final String confirm;
  final String cancel;
  final String emptyList;
  final String emptyListVideo;
  final String emptyListAudio;
  final String emptyListFile;
  final String gallery;
  final String camera;
  final String video;
  final String audio;
  final String file;
  final String permissionRequired;
  final String permissionDenied;
  final String openSettings;
  final String crop;
  final String recent;
  final String all;
  final String maxSelectTitle;
  final String assetDetails;
  final String close;

  const HQPickerLocalizations({
    this.confirm = 'Send',
    this.cancel = 'Cancel',
    this.emptyList = 'No albums found',
    this.emptyListVideo = 'No videos found',
    this.emptyListAudio = 'No audio found',
    this.emptyListFile = 'No files found',
    this.gallery = 'Gallery',
    this.camera = 'Camera',
    this.video = 'Videos',
    this.audio = 'Audios',
    this.file = 'Files',
    this.permissionRequired = 'Permission Required',
    this.permissionDenied = 'Permission Denied. Please allow access from settings.',
    this.openSettings = 'Open Settings',
    this.crop = 'Crop Image',
    this.recent = 'Recent',
    this.all = 'All',
    this.maxSelectTitle = 'Maximum selection limit is',
    this.assetDetails = 'Asset Details',
    this.close = 'Close',
  });

  const HQPickerLocalizations.en() : this();

  const HQPickerLocalizations.ar()
    : this(
        confirm: 'تأكيد',
        cancel: 'إلغاء',
        emptyList: 'لا توجد ألبومات',
        emptyListVideo: 'لا توجد فيديوهات',
        emptyListAudio: 'لا توجد صوتيات',
        emptyListFile: 'لا توجد ملفات',
        gallery: 'المعرض',
        camera: 'الكاميرا',
        video: 'الفيديوهات',
        audio: 'الصوتيات',
        file: 'الملفات',
        permissionRequired: 'مطلوب إذن',
        permissionDenied: 'تم رفض الصلاحية. يرجى السماح للوصول من الإعدادات.',
        openSettings: 'فتح الإعدادات',
        crop: 'قص الصورة',
        recent: 'الأحدث',
        all: 'الكل',
        maxSelectTitle: 'الحد الأقصى للاختيار هو',
        assetDetails: 'تفاصيل العنصر',
        close: 'إغلاق',
      );

  HQPickerLocalizations copyWith({
    String? confirm,
    String? cancel,
    String? emptyList,
    String? emptyListVideo,
    String? emptyListAudio,
    String? emptyListFile,
    String? gallery,
    String? camera,
    String? video,
    String? audio,
    String? file,
    String? permissionRequired,
    String? permissionDenied,
    String? openSettings,
    String? crop,
    String? recent,
    String? all,
    String? maxSelectTitle,
    String? assetDetails,
    String? close,
  }) {
    return HQPickerLocalizations(
      confirm: confirm ?? this.confirm,
      cancel: cancel ?? this.cancel,
      emptyList: emptyList ?? this.emptyList,
      emptyListVideo: emptyListVideo ?? this.emptyListVideo,
      emptyListAudio: emptyListAudio ?? this.emptyListAudio,
      emptyListFile: emptyListFile ?? this.emptyListFile,
      gallery: gallery ?? this.gallery,
      camera: camera ?? this.camera,
      video: video ?? this.video,
      audio: audio ?? this.audio,
      file: file ?? this.file,
      permissionRequired: permissionRequired ?? this.permissionRequired,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      openSettings: openSettings ?? this.openSettings,
      crop: crop ?? this.crop,
      recent: recent ?? this.recent,
      all: all ?? this.all,
      maxSelectTitle: maxSelectTitle ?? this.maxSelectTitle,
      assetDetails: assetDetails ?? this.assetDetails,
      close: close ?? this.close,
    );
  }
}
