import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/http/http.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shosai/utils/log.dart';

DomService domService = DomService();

class DomService {
  DomService._internal();

  static final DomService _domService = DomService._internal();

  factory DomService() => _domService;

  Future<Document?> requestHtml(ZRequest request) async {
    var options = request.options ?? dio.Options(method: "GET");
    options.headers ??= {
      "Content-Type": "text/html; charset=UTF-8",
    };
    options.responseType = dio.ResponseType.bytes;
    request.options = options;
    var response = await HttpRequest.newCall(request).request();
    if(response.isError()) {
      return null;
    }
    try {
      String charset = response.charset ?? 'UTF-8';
      return parse(CharsetDecoder(charset).decode(response.data), encoding: charset);
    } catch(e) {
      return null;
    }

    // if (response.statusCode == HttpStatus.ok) {
    //   print(response.data.toString());
    // } else {
    //   print("Error: ${response.statusCode}");
    // }
  }
}
