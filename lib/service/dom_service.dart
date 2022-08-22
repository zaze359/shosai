import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/http/http.dart';
import 'package:dio/dio.dart' as dio;

DomService domService = DomService();

class DomService {
  DomService._internal();

  static final DomService _domService = DomService._internal();

  factory DomService() => _domService;

  Future<Document> requestHtml(ZRequest request) async {
    var options = request.options ?? dio.Options(method: "GET");
    options.headers ??= {
      "Content-Type": "text/html; charset=UTF-8",
    };
    options.responseType = dio.ResponseType.bytes;
    request.options = options;
    var response = await HttpRequest.newCall(request).request();
    String charset = response.charset ?? 'UTF-8';
    return parse(CharsetDecoder(charset).decode(response.data),
        encoding: charset);
    // if (response.statusCode == HttpStatus.ok) {
    //   print(response.data.toString());
    // } else {
    //   print("Error: ${response.statusCode}");
    // }
  }
}
