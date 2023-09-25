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

  Future<ZResponse> request(ZRequest request) {
    // var a = ZRequest(path: "", body : "", queryParameters: null, options : null);
    return dio.Dio()
        .request(
          request.path,
          data: request.body,
          options: request.options,
          queryParameters: request.queryParameters,
        )
        .then((value) => ZResponse(request: request, response: value))
        .onError((error, stackTrace) {
          if (error is dio.DioError) {
            return ZResponse(request: request, response: error.response);
          } else {
            return ZResponse(request: request, response: null);
          }
        });
  }

  Future<ZResponse> download(DownloadRequest request,
      {OnStart? onStart, OnProgress? onProgress}) {
    // var a = ZRequest(path: "", body : "", queryParameters: null, options : null);
    return dio.Dio().download(
      request.path,
      request.savePath,
      options: request.options,
      queryParameters: request.queryParameters,
      onReceiveProgress: (count, total) {
        // TODO speed
        onProgress?.call(count, total, -1);
      },
    ).then((value) => ZResponse(request: request, response: value)).onError((error, stackTrace) {
      if (error is dio.DioError) {
        return ZResponse(request: request, response: error.response);
      } else {
        return ZResponse(request: request, response: null);
      }
    });
  }
}
