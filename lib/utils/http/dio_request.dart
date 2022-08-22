import 'package:dio/dio.dart' as dio;
import 'package:shosai/utils/http/http.dart';
import 'package:shosai/utils/http/http_download.dart';

DioRequest dioRequest = DioRequest();

class DioRequest {
  DioRequest._();

  static final DioRequest _request = DioRequest._();

  factory DioRequest() {
    return _request;
  }

  Future<ZResponse> request(ZRequest request) async {
    // var a = ZRequest(path: "", body : "", queryParameters: null, options : null);
    dio.Response response = await dio.Dio().request(
      request.path,
      data: request.body,
      options: request.options,
      queryParameters: request.queryParameters,
    );
    return ZResponse(request: request, response: response);
  }

  Future<ZResponse> download(DownloadRequest request,
      {OnStart? onStart,
      OnProgress? onProgress}) async {
    // var a = ZRequest(path: "", body : "", queryParameters: null, options : null);
    dio.Response response = await dio.Dio().download(
      request.path,
      request.savePath,
      options: request.options,
      queryParameters: request.queryParameters,
      onReceiveProgress: (count, total) {
        // TODO speed
        onProgress?.call(count, total, -1);
      },
    );
    return ZResponse(request: request, response: response);
  }
}
