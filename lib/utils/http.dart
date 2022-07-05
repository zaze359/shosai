import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:path/path.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/log.dart';

HttpHelper httpHelper = HttpHelper();

class HttpHelper {
  HttpHelper._();

  static final HttpHelper _helper = HttpHelper._();

  factory HttpHelper() {
    return _helper;
  }

  search(BookSource source, UrlKeys searchKeys) async {
    if(searchKeys.isEmpty()) {
      return;
    }
    String? searchUrl = source.searchUrl.path;
    if (searchUrl == null || searchUrl.isEmpty) {
      bookSourceLog("未获取到搜索地址");
      return;
    }
    if (!searchUrl.startsWith("http")) {
      searchUrl = source.url + searchUrl;
    }
    Map<String, dynamic>? map = searchKeys.combine(source.searchUrl.params);
    //
    bookSourceLog("开始搜索: $searchUrl >> $map");
    bookSourceLog("开始搜索 source: $searchUrl");
    Document document = await requestHtml(
      searchUrl,
      queryParameters: map,
      body: jsonEncode(searchKeys.combine(source.searchUrl.body)),
      options: Options(
        method: source.searchUrl.method ?? "GET",
        headers: {
          "Content-Type": "text/html;charset=UTF-8",
        },
      ),
    );
    bookSourceLog("搜索完成: ${document.outerHtml}");
    SearchRule searchRule = source.searchRule;
    bookSourceLog("开始解析书籍列表");
    List<Element>? elements = searchRule.bookList.getElements(document);
    bookSourceLog("解析结果: $elements");
    if (elements == null || elements.isEmpty) {
      bookSourceLog("解析失败");
      return;
    }
    for (var element in elements) {
      Book book = Book();
      String bookUrl = searchRule.bookUrl.getResult(element);
      if (bookUrl.startsWith("http")) {
        book.id = bookUrl;
      } else {
        book.id = source.url + bookUrl;
      }
      book.name = searchRule.name.getResult(element);
      book.author = searchRule.author.getResult(element);
      book.tags = searchRule.tags.getResult(element, separator: ",");
      book.wordCount = searchRule.wordCount.getResult(element);
      book.updateTime = searchRule.updateTime.getResult(element);
      book.latestChapterTitle = searchRule.latestChapter.getResult(element);

      String coverUrl = searchRule.coverUrl.getResult(element);
      if (coverUrl.isEmpty) {
        book.coverUrl = null;
      } else if (coverUrl.startsWith("http://") ||
          coverUrl.startsWith("https://")) {
        book.coverUrl = coverUrl;
      } else {
        book.coverUrl = source.url + coverUrl;
      }
      book.latestCheckTime = DateTime.now().millisecondsSinceEpoch;
      bookSourceLog("获取到书籍: $book");
    }
  }

  Future<Document> requestHtml(
    String path, {
    String? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // 后续需要根据返回数据的编码进行解码，所以指定字节流返回
    options?.responseType = ResponseType.bytes;
    var response = await request(
      path,
      body: body,
      queryParameters: queryParameters,
      options: options ??
          Options(
            method: "GET",
            headers: {
              "Content-Type": "text/html;charset=UTF-8",
            },
          ),
    );
    String? charset = 'UTF-8';
    response.headers.value('Content-Type')?.split(';').forEach((value) {
      if (value.contains('charset')) {
        charset = value.split('=')[1];
      }
    });
    bookSourceLog("响应结果: ${response.statusCode}; charset: $charset");
    return parse(CharsetDecoder(charset).decode(response.data),
        encoding: charset);

    // if (response.statusCode == HttpStatus.ok) {
    //   print(response.data.toString());
    // } else {
    //   print("Error: ${response.statusCode}");
    // }
  }

  Future<Response> request(
    String path, {
    String? body,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    bookSourceLog(
        "发送http请求: $path; method: ${options?.method}, params: $queryParameters; body: $body");
    return await Dio().request(
      path,
      data: body,
      options: options,
      queryParameters: queryParameters,
    );
  }
}
