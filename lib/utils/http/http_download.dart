import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:shosai/utils/http/dio_request.dart';
import 'package:shosai/utils/http/http.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/utils/utils.dart';

DownloadManager downloadManager = DownloadManager();

/// Description : 下载管理类
/// @author zaze
/// @date 2022/8/9 - 22:25
///
class DownloadManager {
  DownloadManager._();

  static final DownloadManager _manager = DownloadManager._();

  factory DownloadManager() {
    return _manager;
  }

  Map<String, String> urlMap = {};

  /// 任务是否存在
  /// @return true 存在, false 不存在
  bool _isTaskExists(String url) {
    return urlMap.containsKey(url);
  }

  /// 缓存下载任务
  /// [url] url
  void _addDownloadTask(String url) {
    MyLog.d("addDownloadTask : $url");
    urlMap[url] = url;
  }

  /// 清除下载任务缓存
  /// [url] url
  void _removeDownloadTask(String url) {
    MyLog.d("removeDownloadTask : $url");
    urlMap.remove(url);
  }

  download(DownloadRequest request,
      {OnStart? onStart,
      OnProgress? onProgress,
      OnSuccess? onSuccess,
      OnFailure? onFailure}) async {
    String urlPath = request.path;
    String savePath = request.savePath;
    String? md5Str = request.md5;
    MyLog.i("准备下载 url=$urlPath; savePath=$savePath; md5=$md5Str");
    if (_isTaskExists(urlPath)) {
      MyLog.d("当前文件正在下载中: $savePath");
      onFailure?.call(-1, "当前文件正在下载中", savePath);
      return;
    }
    MyLog.i("检测是否已下载 url=$urlPath; savePath=$savePath;");
    File saveFile = File(savePath);

    if (saveFile.existsSync() &&
        (md5Str != null && md5Str == Utils.md5Str(savePath))) {
      MyLog.i("下载文件已存在: $savePath");
      onSuccess?.call(savePath);
      return;
    }
    // _addDownloadTask(url);
    var response = await dioRequest.download(request, onStart: (total) {
      MyLog.i("开始下载: $urlPath; $total");
      onStart?.call(total);
    }, onProgress: (count, total, speed) {
      MyLog.d("onProgress: $urlPath; $count/$total; $speed/s");
      onProgress?.call(count, total, speed);
    });
    //
    if (response.isSuccess()) {
      var value = await Utils.md5File(savePath);
      if (md5Str == null || value == md5Str) {
        MyLog.i("下载完成 url=$savePath; savePath=$savePath;");
        onSuccess?.call(savePath);
      } else {
        MyLog.e("md5校验失败 url=$urlPath; savePath=$savePath;");
        onFailure?.call(-1, "md5校验失败", savePath);
      }
      onSuccess?.call(request.savePath);
    } else {
      MyLog.e(
          "下载失败-$urlPath(${response.statusCode})：${response.response}; url=$urlPath; savePath=$savePath;");
      onFailure?.call(
          -1,
          "下载失败-$urlPath(${response.statusCode})：${response.response}",
          savePath);
    }
  }
}

/// Description :接口请求体
/// @author zaze
/// @date 2022/8/5 - 5:13
class DownloadRequest extends ZRequest {
  String savePath;
  String? md5;

  DownloadRequest(super.url, this.savePath,
      {super.body, super.queryParameters, super.options, this.md5});

  @override
  print() {
    bookSourceLog(
        "发送下载请求: 【$path】>> 【$savePath】; method: ${options?.method}, params: $queryParameters;");
  }
}

/// 开始
/// [total] 文件大小
typedef OnStart = void Function(int total);

/// 进度
/// [count]  文件总大小
/// [total]  已下载大小
/// [speed]  下载速度
typedef OnProgress = void Function(int count, int total, double speed);

/// 下载成功回调
/// [savePath] 保存路径
/// [speed]    下载速度
typedef OnSuccess = void Function(String savePath);

/// 下载失败回调
/// [errorCode]    描述信息
/// [errorMessage] 描述信息
/// [savePath]     保存路径
typedef OnFailure = void Function(
    int errorCode, String errorMessage, String savePath);
