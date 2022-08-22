import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/utils/utils.dart';

/// 从本地导入书籍
Future<List<File>> importBookFormLocal() async {
  if (Platform.isAndroid) {
    return await importDirectory();
  } else {
    return await importFiles();
  }
}

Future<List<File>> importFiles() async {
  MyLog.d("import", "importFiles start");
  bool isGranted = await Utils.checkPermission();
  List<File> files = [];
  if (isGranted) {
    List<PlatformFile>? _paths = (await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      onFileLoading: (FilePickerStatus status) => print(status),
      allowedExtensions: ["txt"],
    ))
        ?.files;
    _paths?.forEach((element) {
      String? path = element.path;
      if (path != null) {
        files.add(File(path));
      }
    });
  }
  MyLog.d("import", "importFiles: $files");
  return files;
}

Future<List<File>> importDirectory() async {
  MyLog.d("import", "importDirectory start");
  bool isGranted = await Utils.checkPermission();
  List<File> files = [];
  if (isGranted) {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      MyLog.d("import", "selectedDirectory: $selectedDirectory");
      Directory(selectedDirectory).listSync().where((element) {
        MyLog.d("import", "book file: ${element.absolute.path}");
        return element.absolute.path.endsWith(".txt");
      }).forEach((element) {
        files.add(File(element.absolute.path));
      });
    }
  }
  MyLog.d("import", "importDirectory: $files");
  return files;
}

void remote() {}
