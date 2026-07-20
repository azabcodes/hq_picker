import 'package:flutter/material.dart';
import 'package:flutter_saver/flutter_saver.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

List<String> allowedExtensions = [
  // Textual and administrative documents
  '.doc', '.docx', '.rtf', '.txt', '.odt', '.pdf',
  '.xls', '.xlsx', '.csv', '.ods',
  '.ppt', '.pptx', '.odp',

  // Compressed files
  '.zip', '.rar', '.7z', '.tar', '.gz',

  "wbs",

  // Design and engineering files
  '.dwg', '.dxf', '.dwf', // AutoCAD
  '.skp', // SketchUp
  '.psd', // Photoshop
  '.ai', '.eps', // Adobe Illustrator
  '.indd', // Adobe InDesign
  '.blend', // Blender
  // Programming and web files
  '.html', '.css', '.js', '.php', '.py', '.java', '.cpp', '.c', '.h',
  '.swift', '.kt', '.dart', '.go', '.rb', '.pl', '.sql',

  // Executable and installation files
  '.exe', '.msi', '.apk', '.app',

  // System and configuration files
  '.ini', '.cfg', '.conf', '.log', '.sys',

  // Database files
  '.db', '.sqlite', '.mdb', '.accdb',

  // Font files
  '.ttf', '.otf', '.woff', '.woff2',

  // Email files
  '.eml', '.msg',

  // 3D modeling files
  '.obj', '.fbx', '.3ds', '.max',

  // GIS and map files
  '.shp', '.kml', '.kmz',

  // Scientific and research files
  '.mat', '.nb', '.r', '.sav',

  // E-book files
  '.epub', '.mobi',

  // Virtual machine files
  '.vdi', '.vmdk', '.ova',

  // Backup files
  '.bak', '.old', '.backup',
];

List<String> common = [
  // Text documents and word processing
  '.txt', '.doc', '.docx', '.rtf', '.odt', '.pages',

  // PDF files
  '.pdf',

  // Spreadsheets
  '.xls', '.xlsx', '.csv', '.ods', '.numbers',

  // Presentations
  '.ppt', '.pptx', '.key', '.odp',

  // Compressed files
  '.zip', '.rar', '.7z', '.tar', '.gz',

  // Image files
  '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.tiff', '.webp',

  // Audio files
  '.mp3', '.wav', '.aac', '.ogg', '.flac',

  // Video files
  '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv',

  // Programming files and code
  '.html', '.css', '.js', '.json', '.xml', '.py', '.java', '.cpp', '.c',
  '.swift', '.kt',

  // System and configuration files
  '.ini', '.cfg', '.log', '.dat',

  // Email files
  '.eml', '.msg',

  // Font files
  '.ttf', '.otf', '.woff', '.woff2',

  // Database files
  '.db', '.sqlite', '.sql',

  // Executable files (use with caution)
  '.exe', '.app', '.dmg',

  // Vector files and design
  '.svg', '.ai', '.eps', '.psd',

  // E-book files
  '.epub', '.mobi',

  // Web related files
  '.htm', '.php', '.asp', '.jsp',

  // Files related to virtualization
  '.iso', '.vdi', '.vmdk',

  // and other common formats
];

List<String> allowedExtensionsVideo = [
  // Video files
  '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv',
];

List<String> allowedExtensionsAudio = [
  // Audio files
  '.mp3', '.wav', '.aac', '.ogg', '.flac', '.amr', '.m4a', '.wma',
];

Future<List<DirectoryType>> getPublicDirectories() async {
  return [
    DirectoryType.downloads,
    DirectoryType.music,
    DirectoryType.podcasts,
    DirectoryType.ringtones,
    DirectoryType.alarms,
    DirectoryType.notifications,
    DirectoryType.pictures,
    DirectoryType.movies,
    DirectoryType.dim,
    DirectoryType.documents,
    DirectoryType.screenshots,
    DirectoryType.audiobooks,
  ];
}

Widget getIconForFile(String extension) {
  Map<String, IconData> icons = {
    '.doc': LucideIcons.fileArchive,
    '.docx': LucideIcons.fileArchive,
    '.rtf': LucideIcons.fileArchive,
    '.txt': LucideIcons.fileText,
    '.odt': LucideIcons.fileArchive,
    '.pdf': LucideIcons.fileHeart,
    '.xls': LucideIcons.chartBar,
    '.xlsx': LucideIcons.chartBar,
    '.csv': LucideIcons.chartBar,
    '.ods': LucideIcons.chartBar,
    '.ppt': LucideIcons.file,
    '.pptx': LucideIcons.file,
    '.odp': LucideIcons.file,
    '.zip': LucideIcons.archive,
    '.rar': LucideIcons.archive,
    '.7z': LucideIcons.archive,
    '.tar': LucideIcons.archive,
    '.gz': LucideIcons.archive,
    '.wbs': LucideIcons.file,
    '.dwg': LucideIcons.ruler,
    '.dxf': LucideIcons.ruler,
    '.dwf': LucideIcons.ruler,
    '.skp': LucideIcons.file,
    '.psd': LucideIcons.image,
    '.ai': LucideIcons.brush,
    '.eps': LucideIcons.brush,
    '.indd': LucideIcons.book,
    '.blend': LucideIcons.file,
    '.html': LucideIcons.code,
    '.css': LucideIcons.code,
    '.js': Icons.javascript,
    '.php': Icons.php,
    '.py': LucideIcons.code,
    '.java': Icons.javascript_sharp,
    '.cpp': LucideIcons.code,
    '.c': LucideIcons.code,
    '.h': LucideIcons.code,
    '.swift': LucideIcons.code,
    '.kt': LucideIcons.code,
    '.dart': LucideIcons.code,
    '.go': LucideIcons.code,
    '.rb': LucideIcons.code,
    '.pl': LucideIcons.code,
    '.sql': LucideIcons.database,
    '.mp3': LucideIcons.music,
    '.wav': LucideIcons.fileAudio,
    '.ogg': LucideIcons.fileAudio2,
    '.flac': LucideIcons.music4,
    '.aac': LucideIcons.music2,
    '.wma': LucideIcons.play,
    '.mp4': LucideIcons.video,
    '.avi': LucideIcons.video,
    '.mov': LucideIcons.video,
    '.wmv': LucideIcons.video,
    '.flv': LucideIcons.video,
    '.mkv': LucideIcons.video,
    '.exe': LucideIcons.video,
    '.msi': LucideIcons.code,
    '.apk': Icons.android,
    '.app': Icons.apple,
    '.ini': LucideIcons.settings,
    '.cfg': LucideIcons.settings,
    '.conf': LucideIcons.settings,
    '.log': LucideIcons.fileText,
    '.sys': LucideIcons.cpu,
    '.db': LucideIcons.database,
    '.sqlite': LucideIcons.database,
    '.mdb': LucideIcons.database,
    '.accdb': LucideIcons.database,
    '.ttf': LucideIcons.text,
    '.otf': LucideIcons.text,
    '.woff': LucideIcons.text,
    '.woff2': LucideIcons.text,
    '.eml': LucideIcons.mail,
    '.msg': LucideIcons.messagesSquare,
    '.obj': Icons.data_object,
    '.fbx': LucideIcons.file,
    '.3ds': LucideIcons.file,
    '.max': LucideIcons.file,
    '.shp': LucideIcons.map,
    '.kml': LucideIcons.map,
    '.kmz': LucideIcons.map,
    '.mat': LucideIcons.file,
    '.nb': LucideIcons.notebook,
    '.r': LucideIcons.code,
    '.sav': LucideIcons.save,
    '.epub': LucideIcons.book,
    '.mobi': LucideIcons.book,
    '.vdi': LucideIcons.monitor,
    '.vmdk': LucideIcons.monitor,
    '.ova': LucideIcons.monitor,
    '.bak': LucideIcons.refreshCcw,
    '.old': LucideIcons.clock,
    '.backup': LucideIcons.refreshCcwDot,
    '.jpg': LucideIcons.galleryThumbnails,
    '.jpeg': LucideIcons.galleryVertical,
    '.png': LucideIcons.galleryThumbnails,
    '.gif': LucideIcons.galleryThumbnails,
  };

  Map<String, Color> colors = {
    '.doc': Colors.blue,
    '.docx': Colors.blue,
    '.rtf': Colors.blueGrey,
    '.txt': Colors.grey,
    '.odt': Colors.teal,
    '.pdf': Colors.red,
    '.xls': Colors.green,
    '.xlsx': Colors.green,
    '.csv': Colors.lightGreen,
    '.ods': Colors.lightGreen,
    '.ppt': Colors.orange,
    '.pptx': Colors.orange,
    '.odp': Colors.deepOrange,
    '.zip': Colors.purple,
    '.rar': Colors.deepPurple,
    '.7z': Colors.purple,
    '.tar': Colors.purpleAccent,
    '.gz': Colors.deepPurple,
    '.wbs': Colors.brown,
    '.dwg': Colors.indigo,
    '.dxf': Colors.indigo,
    '.dwf': Colors.indigo,
    '.skp': Colors.cyan,
    '.psd': Colors.deepPurple,
    '.ai': Colors.orange,
    '.eps': Colors.orange,
    '.indd': Colors.pink,
    '.blend': Colors.lightBlue,
    '.html': Colors.orangeAccent,
    '.css': Colors.blue,
    '.js': Colors.yellow,
    '.php': Colors.indigo,
    '.py': Colors.green,
    '.java': Colors.brown,
    '.cpp': Colors.lightBlue,
    '.c': Colors.blue,
    '.h': Colors.blueGrey,
    '.swift': Colors.orange,
    '.kt': Colors.purple,
    '.dart': Colors.blue,
    '.go': Colors.cyan,
    '.rb': Colors.red,
    '.pl': Colors.indigo,
    '.sql': Colors.teal,
    '.mp3': Colors.pink,
    '.wav': Colors.pinkAccent,
    '.ogg': Colors.deepPurple,
    '.flac': Colors.purple,
    '.aac': Colors.purpleAccent,
    '.wma': Colors.pink,
    '.mp4': Colors.redAccent,
    '.avi': Colors.red,
    '.mov': Colors.deepOrange,
    '.wmv': Colors.orange,
    '.flv': Colors.amber,
    '.mkv': Colors.deepOrange,
    '.exe': Colors.grey,
    '.msi': Colors.blueGrey,
    '.apk': Colors.green,
    '.app': Colors.deepPurple,
    '.ini': Colors.grey,
    '.cfg': Colors.blueGrey,
    '.conf': Colors.grey,
    '.log': Colors.brown,
    '.sys': Colors.blueGrey,
    '.db': Colors.teal,
    '.sqlite': Colors.tealAccent,
    '.mdb': Colors.green,
    '.accdb': Colors.lightGreen,
    '.ttf': Colors.deepPurple,
    '.otf': Colors.purple,
    '.woff': Colors.purpleAccent,
    '.woff2': Colors.deepPurpleAccent,
    '.eml': Colors.red,
    '.msg': Colors.redAccent,
    '.obj': Colors.brown,
    '.fbx': Colors.amber,
    '.3ds': Colors.orange,
    '.max': Colors.deepOrange,
    '.shp': Colors.green,
    '.kml': Colors.lightGreen,
    '.kmz': Colors.lime,
    '.mat': Colors.blue,
    '.nb': Colors.indigo,
    '.r': Colors.red,
    '.sav': Colors.teal,
    '.epub': Colors.green,
    '.mobi': Colors.lightGreen,
    '.vdi': Colors.grey,
    '.vmdk': Colors.blueGrey,
    '.ova': Colors.grey,
    '.bak': Colors.amber,
    '.old': Colors.brown,
    '.backup': Colors.orange,
    '.jpg': Colors.blue,
    '.jpeg': Colors.blue,
    '.png': Colors.blue,
    '.gif': Colors.purple,
  };

  IconData iconData = icons[extension.toLowerCase()] ?? Icons.insert_drive_file;
  Color color = colors[extension.toLowerCase()] ?? Colors.grey;

  return Icon(iconData, color: color);
}
