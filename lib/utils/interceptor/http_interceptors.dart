import 'package:dio/dio.dart' as dio;
import 'package:shosai/utils/http/http.dart';
import 'package:shosai/utils/interceptor/interceptor.dart';

class HttpLogInterceptor implements Interceptor<ZRequest, Future<ZResponse>> {
  @override
  Future<ZResponse> intercept(Chain<ZRequest, Future<ZResponse>> chain) async {
    var request = chain.input();
    request.print();
    var response = await chain.process(request);
    response.print();
    return response;
  }
}

/// Description : 当数据为字节流返回时，需要根据返回数据的编码进行解码，此处从headers中获取对应的编码格式
/// @author zaze
/// @date 2022/8/5 - 6:35
class CharsetInterceptor implements Interceptor<ZRequest, Future<ZResponse>> {
  @override
  Future<ZResponse> intercept(Chain<ZRequest, Future<ZResponse>> chain) async {
    var request = chain.input();
    var response = await chain.process(request);
    if (request.options?.responseType == dio.ResponseType.bytes) {
      String? charset;
      response.response?.headers
          .value('Content-Type')
          ?.split(';')
          .forEach((value) {
        if (value.contains('charset')) {
          charset = value.split('=')[1];
        }
      });
      response.charset = charset;
    }
    return response;
  }
}
