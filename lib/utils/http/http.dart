import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:shosai/utils/http/dio_request.dart';
import 'package:shosai/utils/interceptor/http_interceptors.dart';
import 'package:shosai/utils/interceptor/interceptor.dart';
import 'package:shosai/utils/log.dart';

/// Description : http请求
/// @author zaze
/// @date 2022/8/5 - 5:00
class HttpRequest {
  final ZRequest _request;

  HttpRequest.newCall(this._request);

  Future<ZResponse> request() async {
    return _RealCall(_request).execute();
  }
}

/// Description :接口请求体
/// @author zaze
/// @date 2022/8/5 - 5:13
class ZRequest {
  String path;
  String? body;
  Map<String, dynamic>? queryParameters;
  dio.Options? options;

  ZRequest(this.path, {this.body, this.queryParameters, this.options});

  print() {
    bookSourceLog(
        "发送http请求: $path; method: ${options?.method}, params: $queryParameters; body: $body");
  }
}

/// Description : 接口响应体
/// @author zaze
/// @date 2022/8/5 - 5:13
class ZResponse<T> {
  ZRequest request;

  T? data;
  int? statusCode;

  String? charset;

  dio.Response<T>? response;

  ZResponse({required this.request, this.response}) {
    this.data = response?.data;
    this.statusCode = response?.statusCode;
  }

  bool isSuccess() {
    return statusCode == HttpStatus.ok;
  }

  bool isError() {
    return !isSuccess();
  }
  print() {
    bookSourceLog("响应结果: ${response?.statusCode}; charset: $charset");
  }
}


class _RealCall {
  ZRequest request;

  // List<Interceptor<ZRequest, Future<ZResponse>>> interceptors = [];
  _RealCall(this.request);

  Future<ZResponse> execute() async {
    return _getResponseWhitChain();
  }

  Future<ZResponse> _getResponseWhitChain() async {
    List<Interceptor<ZRequest, Future<ZResponse>>> interceptorList = [];
    interceptorList.add(HttpLogInterceptor());
    // interceptorList.addAll(interceptors)
    interceptorList.add(CharsetInterceptor());
    interceptorList.add(_RealRequest());
    return RealInterceptorChain(interceptorList, request).process(request);
  }
}

class _RealRequest implements Interceptor<ZRequest, Future<ZResponse>> {
  // Future<dio.Response> request(String path, {String? body, Map<String, dynamic>? queryParameters, dio.Options? options,}) async {
  //   return await dio.Dio().request(
  //     path,
  //     data: body,
  //     options: options,
  //     queryParameters: queryParameters,
  //   );
  // }

  @override
  Future<ZResponse> intercept(Chain<ZRequest, Future<ZResponse>> chain) async {
    var request = chain.input();
    // if(request.path.isEmpty) {
    //   var response = ZResponse(request: request);
    // }
    var options = request.options ?? dio.Options(method: "GET");
    options.headers ??= {
      "Content-Type": "application/json; charset=UTF-8",
    };
    options.responseType = dio.ResponseType.bytes;
    return dioRequest.request(request);
  }
}
