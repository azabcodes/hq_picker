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
  final String permissionDenied;
  final String openSettings;
  final String crop;

  const HQPickerLocalizations({
    this.confirm = 'Confirm',
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
    this.permissionDenied = 'Permission Denied. Please allow access from settings.',
    this.openSettings = 'Open Settings',
    this.crop = 'Crop Image',
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
        permissionDenied: 'تم رفض الصلاحية. يرجى السماح للوصول من الإعدادات.',
        openSettings: 'فتح الإعدادات',
        crop: 'قص الصورة',
      );
}
