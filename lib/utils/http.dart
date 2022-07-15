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
import 'package:shosai/utils/rule_convert.dart';

HttpHelper httpHelper = HttpHelper();

class HttpHelper {
  HttpHelper._();

  static final HttpHelper _helper = HttpHelper._();

  factory HttpHelper() {
    return _helper;
  }

  Future<List<Book>> search(BookSource? source, UrlKeys searchKeys) async {
    if (source == null || searchKeys.isEmpty()) {
      return [];
    }
    String? searchUrl = source.searchUrl.path;
    if (searchUrl == null || searchUrl.isEmpty) {
      bookSourceLog("未获取到搜索地址");
      return [];
    }
    searchUrl = appendUrl(source.url, searchUrl);
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
          "user-agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.51",
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
      return [];
    }
    List<Book> searchedBooks = [];
    for (var element in elements) {
      BookUrl bookUrl = BookUrl();
      ConvertRule().convertBookUrl(bookUrl,
          appendUrl(source.url, searchRule.bookUrl.getResult(element)));
      Book book = Book(id: jsonEncode(bookUrl));

      book.origin = source.url;
      book.name = searchRule.name.getResult(element);
      book.author = searchRule.author.getResult(element);
      book.tags = searchRule.tags.getResult(element, separator: ",");
      book.wordCount = searchRule.wordCount.getResult(element);
      book.updateTime = searchRule.updateTime.getResult(element);
      book.latestChapterTitle = searchRule.latestChapter.getResult(element);
      String coverUrl = searchRule.coverUrl.getResult(element);
      book.coverUrl = appendUrl(source.url, coverUrl);
      // String tocUrl = searchRule.bookList.getResult(element);
      // book.tocUrl = append(source.url, coverUrl);

      book.latestCheckTime = DateTime.now().millisecondsSinceEpoch;
      bookSourceLog("获取到书籍: $book");
      searchedBooks.add(book);
    }
    return searchedBooks;
  }

  String appendUrl(String preUrl, String? url) {
    if (url == null || url.isEmpty) {
      return preUrl;
    } else if (url.startsWith("http://") || url.startsWith("https://")) {
      return url;
    } else {
      return preUrl + url;
    }
  }

  Future<Book> requestBookInfo(Book book, BookSource? source) async {
    if (source == null) {
      return book;
    }
    bookSourceLog("获取书籍详情: ${book.id}; $source");
    BookUrl bookUrl = BookUrl.fromJson(jsonDecode(book.id));
    String? path = bookUrl.path;
    if (path == null) {
      bookSourceLog("未获取到书籍地址");
      return book;
    }
    UrlKeys keys = UrlKeys();
    Map<String, dynamic>? map = keys.combine(bookUrl.params);
    Document document = await requestHtml(
      path,
      queryParameters: map,
      body: jsonEncode(keys.combine(bookUrl.body)),
      options: Options(
        method: bookUrl.method ?? "GET",
        headers: {
          "Content-Type": "text/html;charset=UTF-8",
          "user-agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.51",
        },
      ),
    );
    bookSourceLog("书籍详情获取完成: ${document.outerHtml}");
    BookInfoRule rule = source.bookInfoRule;
    bookSourceLog("开始解析书籍详情: $rule");
    book.name = rule.name.getResult(document);
    book.author = rule.author.getResult(document);
    book.intro = rule.intro.getResult(document);
    book.tags = rule.tags.getResult(document, separator: ",");
    book.latestChapterTitle = rule.lastChapter.getResult(document);
    book.coverUrl = appendUrl(source.url, rule.coverUrl.getResult(document));
    book.tocUrl = jsonEncode(ConvertRule().convertBookUrl(
      BookUrl(),
      appendUrl(
        bookUrl.path ?? "",
        rule.tocUrl.getResult(document),
      ),
    ));
    return book;
  }

  Future<List<BookChapter>> requestToc(Book? book, BookSource? source) async {
    String? tocUrl = book?.tocUrl;
    if (book == null  || tocUrl == null || source == null) {
      return [];
    }
    bookSourceLog("获取标题列表: $tocUrl");
    String? path = BookUrl.fromJson(jsonDecode(tocUrl)).path;
    if (path == null || path.isEmpty) {
      bookSourceLog("未获取到目录地址");
      return [];
    }
    Document document = await requestHtml(
      path,
      // queryParameters: map,
      // body: jsonEncode(searchKeys.combine(source.searchUrl.body)),
      options: Options(
        method: source.searchUrl.method ?? "GET",
        headers: {
          "Content-Type": "text/html;charset=UTF-8",
          "user-agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.114 Safari/537.36 Edg/103.0.1264.51",
        },
      ),
    );
    bookSourceLog("标题列表获取完成: ${document.outerHtml}");
    TocRule tocRule = source.tocRule;
    bookSourceLog("开始解析标题列表");
    List<Element>? elements = tocRule.chapterList.getElements(document);
    bookSourceLog("解析结果: $elements");
    if (elements == null || elements.isEmpty) {
      bookSourceLog("解析失败");
      return [];
    }
    List<BookChapter> list = [];
    for (var element in elements) {
      try {
        BookUrl url = BookUrl();
        ConvertRule().convertBookUrl(
            url, appendUrl(book.origin, tocRule.chapterUrl.getResult(element)));
        BookChapter bookChapter = BookChapter(
            bookId: book.id,
            index: list.length,
            title: tocRule.chapterName.getResult(element),
            url: jsonEncode(url));
        bookSourceLog("bookChapter: $bookChapter");
        list.add(bookChapter);
      } catch (e, s) {
        printD("requestToc parseToc error: $e  $s");
      }
    }
    return list;
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
