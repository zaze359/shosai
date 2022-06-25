import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/log.dart';

class FileService {
  static Future<Directory> _getRootDir(DirectoryType storageType) async {
    switch (storageType) {
      case DirectoryType.cache:
        return await path_provider.getTemporaryDirectory();
      case DirectoryType.document:
        return await path_provider.getApplicationDocumentsDirectory();
      case DirectoryType.support:
        return await path_provider.getApplicationSupportDirectory();
      case DirectoryType.external:
        return await path_provider.getExternalStorageDirectory() ??
            await path_provider.getApplicationDocumentsDirectory();
    }
  }

  static Future<Directory> cacheDir() {
    return _getRootDir(DirectoryType.cache);
  }

  static Future<Directory> documentDir() {
    return _getRootDir(DirectoryType.document);
  }

  static Future<Directory> supportDir() {
    return _getRootDir(DirectoryType.support);
  }

  static Future<Directory> externalDir() {
    return _getRootDir(DirectoryType.external);
  }

  /// 拼接路径
  static Future<String> joinPath(DirectoryType storageType, String path) async {
    return "${(await _getRootDir(storageType)).path}/$path";
  }

  // Future<String> get _localPath async {
  //   Directory? directory;
  //   try {
  //     // directory = await getTemporaryDirectory(); // /data/user/0/com.zaze.myapp/cache
  //     // directory = await getTemporaryDirectory(); // /data/user/0/com.zaze.myapp/cache
  //     // directory = await getApplicationSupportDirectory(); // /data/user/0/com.zaze.myapp/files
  //     directory =
  //     await getExternalStorageDirectory(); // /storage/emulated/0/Android/data/com.zaze.myapp/files
  //     // directory = await getDownloadsDirectory();
  //     print("_localPath1: ${directory?.path}");
  //   } catch (e) {
  //     print("_localPath e: ${e}");
  //   }
  //   directory ??=
  //   await getApplicationDocumentsDirectory(); // /data/user/0/com.zaze.myapp/app_flutter
  //   // final directory = await getTemporaryDirectory();
  //   print("_localPath2: ${directory.path}");
  //   return directory.path;
  // }

  /// check [Permission.storage] permission
  /// if [manageExternal] is true, also check [Permission.manageExternalStorage] permission.
  static Future<bool> checkPermission(
      {bool externalStorage = false, bool manageExternal = false}) async {
    if (externalStorage && Platform.isAndroid) {
      if (!await Permission.storage.isGranted) {
        var state = await Permission.storage.request();
        if (!state.isGranted) {
          MyLog.i("checkPermission", "storage permission ${state.name}");
          return false;
        }
      }
      if (manageExternal && !await Permission.manageExternalStorage.isGranted) {
        var state = await Permission.manageExternalStorage.request();
        if (!state.isGranted) {
          MyLog.i("checkPermission",
              "manageExternalStorage permission ${state.name}");
          return false;
        }
      }
    }
    return true;
  }

  /// create directory
  static Future<bool> createDirectory(String path,
      {bool recursive = false,
      bool externalStorage = false,
      bool manageExternal = false}) async {
    MyLog.d("createDirectory", "$path;");
    if (path.isEmpty) {
      return false;
    }
    if (!await checkPermission(
        externalStorage: externalStorage, manageExternal: manageExternal)) {
      return false;
    }

    if (await FileSystemEntity.isFile(path)) {
      MyLog.d("createDirectory", "$path is exists a file");
      return false;
    }
    try {
      Directory directory = Directory(path);
      if (!directory.existsSync()) {
        directory.createSync(recursive: recursive);
      }
      return true;
    } catch (e) {
      MyLog.d("createDirectory", "error: $e; [$path]");
      return false;
    }
  }

  /// delete directory
  static Future<bool> deleteDirectory(String path,
      {bool recursive = false,
      bool externalStorage = false,
      bool manageExternal = false}) async {
    MyLog.d("createDirectory", "$path; $recursive");
    if (path.isEmpty) {
      return false;
    }
    if (!await checkPermission(
        externalStorage: externalStorage, manageExternal: manageExternal)) {
      return false;
    }
    if (await FileSystemEntity.isFile(path)) {
      MyLog.d("createDirectory", "$path is exists a file");
      return false;
    }
    try {
      Directory directory = Directory(path);
      if (!directory.existsSync()) {
        directory.createSync(recursive: recursive);
      }
      return true;
    } catch (e) {
      MyLog.d("createDirectory", "error: $e; [$path]");
      return false;
    }
  }

  // --------------------------------------------------
  /// read [content] from [path] file by Stream。
  /// charset = null, 默认自动匹配字符集
  static Stream<String> readByStream(String path,
      {int? start, int? end, String? charset}) {
    try {
      Stream<List<int>> inputStream = openRead(path, start: start, end: end);
      return CharsetDecoder(charset).bind(inputStream);
      // .transform(const LineSplitter());
    } catch (e) {
      return const Stream<String>.empty();
    }
  }

  static Stream<List<int>> openRead(String? localPath, {int? start, int? end}) {
    try {
      if (localPath == null || localPath.isEmpty) {
        return const Stream.empty();
      }
      File file = File(localPath);
      if (!file.existsSync()) {
        return const Stream.empty();
      }
      return file.openRead(start, end);
    } catch (e) {
      return const Stream.empty();
    }
  }

  /// read [content] from [path] file。
  static Future<String> readAsString(String path,
      {bool externalStorage = false,
      bool manageExternal = false,
      Encoding encoding = utf8}) async {
    if (!await checkPermission(
        externalStorage: externalStorage, manageExternal: manageExternal)) {
      return "";
    }
    try {
      File file = File(path);
      if (!file.existsSync()) {
        return "";
      }
      final contents = file.readAsString(encoding: encoding);
      return contents;
    } catch (e) {
      return "";
    }
  }

  /// write [content] into [path] file。
  static Future<File> writeAsString(String path, String content,
      {bool externalStorage = false, bool manageExternal = false}) async {
    File file = File(path);
    if (!await checkPermission(
        externalStorage: externalStorage, manageExternal: manageExternal)) {
      return file;
    }
    if (!file.existsSync()) {
      file.createSync();
    }
    return file.writeAsString(content);
  }

  /// write [content] into [path] file。
  static Future<bool> deleteFile(String path,
      {bool externalStorage = false, bool manageExternal = false}) async {
    File file = File(path);
    if (!await checkPermission(
        externalStorage: externalStorage, manageExternal: manageExternal)) {
      return false;
    }
    try {
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      return false;
    }
    return true;
  }
}

enum DirectoryType {
  ///
  /// Android: getFilesDir()   /data/user/0/com.zaze.myapp/files
  /// IOS: NSApplicationSupportDirectory
  support,

  /// 缓存目录
  /// Android: getCacheDir()   /data/user/0/com.zaze.myapp/cache
  /// IOS: NSCachesDirectory
  cache,

  /// 外置目录
  /// Android: getExternalFilesDir(null)
  /// IOS: UnsupportedError
  external,

  // /// 下载目录
  // /// only desktop operating systems
  // /// other UnsupportedError
  // download,

  /// 文档
  /// Android: AppData目录  /data/user/0/com.zaze.myapp/app_flutter
  /// IOS: NSDocumentDirectory
  document,
}
