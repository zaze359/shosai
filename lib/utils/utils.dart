import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shosai/utils/log.dart';

class Utils {

  static String md5(List<int> content) {
    return crypto.md5.convert(content).toString().toUpperCase();
  }

  // static String md5Str(String content) {
  //   var encoder = CharsetEncoder();
  //   var md5List = md5(encoder.convert(content));
  //   printD("md5Str: $content (${encoder.charset})");
  //   return CharsetDecoder(encoder.charset).convert(md5List);
  // }
  //
  // static Future<String> md5File(String path) async {
  //   var bytes = await File(path).readAsBytes();
  //   return CharsetDecoder().convert(md5(bytes));
  // }

  static String md5Str(String content) {
    // printD("md5Str: $content");
    return md5(utf8.encode(content));
  }

  static Future<String> md5File(String path) async {
    var bytes = await File(path).readAsBytes();
    return md5(bytes);
  }

  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo? info = await (DeviceInfoPlugin().androidInfo);

      int version = (info.version.sdkInt ?? 0);
      bool manageExternalStorage = false;
      bool storage = false;
      if (version < 33) {
        storage = (await Permission.storage.request()).isGranted;
      } else {
        // 33以后 WRITE_EXTERNAL_STORAGE，READ_EXTERNAL_STORAGE权限 不可用了
        // 直接置为true，忽略这两个权限
        storage = true;
      }
      if (version >= 31) { // 31开始新增 manageExternalStorage 文件管理权限
        manageExternalStorage = (await Permission.manageExternalStorage.request()).isGranted;
      } else {
        manageExternalStorage = true;
      }
      MyLog.d("checkPermission storage: $storage");
      MyLog.d("checkPermission manageExternalStorage: $manageExternalStorage");
      return storage && manageExternalStorage;

      if (version >= 31) {
        MyLog.d("checkPermission manageExternalStorage: ${await Permission
            .manageExternalStorage.request()}");
        return await Permission.storage.isGranted &&
            await Permission.manageExternalStorage.isGranted;
      }
      return await Permission.storage.isGranted;
    } else {
      return true;
    }
  }

}
