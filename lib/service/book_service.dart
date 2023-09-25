import 'dart:convert';

import 'package:dio/dio.dart' as dio;

import 'package:html/dom.dart';
import 'package:shosai/core/common/di.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/service/dom_service.dart';
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/http/http.dart';
import 'package:shosai/utils/http/http_download.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/utils/rule_convert.dart';
import 'package:shosai/utils/utils.dart';

import '../core/data/repository/book_repository.dart';

BookService bookService = BookService();

class BookService {
  BookService._internal();

  static final BookService _bookService = BookService._internal();
  BookRepository bookRepository = Injector.instance.get<BookRepository>();

  factory BookService() => _bookService;

  /// 搜索书籍
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
    Document? document = await domService.requestHtml(
      ZRequest(
        searchUrl,
        queryParameters: map,
        body: jsonEncode(searchKeys.combine(source.searchUrl.body)),
        options: dio.Options(
          method: source.searchUrl.method ?? "GET",
        ),
      ),
    );
    if(document == null) {
       bookSourceLog("未获取到内容: $searchUrl");
       source.markError();
       return [];
    }
    source.markSuccess();
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

  /// 请求书籍详情
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
    Document? document = await domService.requestHtml(
      ZRequest(
        path,
        queryParameters: map,
        body: jsonEncode(keys.combine(bookUrl.body)),
        options: dio.Options(method: bookUrl.method ?? "GET"),
      ),
    );
    if(document == null) {
      bookSourceLog("未获取到内容: ${source.url}");
      return book;
    }
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

  /// 请求书籍目录信息
  Future<List<BookChapter>> requestToc(Book? book, BookSource? source) async {
    String? tocUrl = book?.tocUrl;
    if (book == null || tocUrl == null || source == null) {
      return [];
    }
    bookSourceLog("获取标题列表: $tocUrl");
    String? path = BookUrl.fromJson(jsonDecode(tocUrl)).path;
    if (path == null || path.isEmpty) {
      bookSourceLog("未获取到目录地址");
      return [];
    }
    Document? document = await domService.requestHtml(
      ZRequest(
        path,
        options: dio.Options(method: source.searchUrl.method ?? "GET"),
      ),
    );

    if(document == null) {
      bookSourceLog("未获取到内容: ${source.url}");
      return [];
    }
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

  /// 下载章节内容
  /// [bookChapter] 章节信息
  downloadChapter(BookSource? bookSource, BookChapter chapter,
      {OnStart? onStart,
      OnProgress? onProgress,
      OnSuccess? onSuccess,
      OnFailure? onFailure}) async {
    // String savePath =
    //     "${(await FileService.externalDir())}/${chapter.title}_${chapter.index}.txt";
    String savePath =
        "${await FileService.externalDir()}/${Utils.md5Str(chapter.bookId)}/${chapter.title}_${chapter.index}.txt";
    String? url = chapter.url;
    if (url == null || url.isEmpty) {
      onFailure?.call(-1, "下载地址不能为空", savePath);
      return;
    }
    BookUrl bookUrl = BookUrl.fromJson(jsonDecode(chapter.url!));
    String? urlPath = bookUrl.path;
    if (urlPath == null) {
      onFailure?.call(-1, "无法解析到下载地址", savePath);
      return;
    }
    UrlKeys keys = UrlKeys();
    ContentRule? contentRule = bookSource?.contentRule;

    Document? document = await domService.requestHtml(
      ZRequest(urlPath,
          queryParameters: keys.combine(bookUrl.params),
          options: dio.Options(method: bookUrl.method ?? "GET")),
    );
    if(document == null) {
      bookSourceLog("未获取到内容: $urlPath");
      return;
    }
    bookSourceLog("开始解析章节内容: $contentRule");
    String content;
    if (contentRule != null) {
      content = contentRule.content.getResult(document);
    } else {
      content = document.body?.innerHtml ?? "";
    }
    bookSourceLog("章节内容解析结果: $content");
    bookSourceLog("保存到本地: $savePath");
    await FileService.writeAsString(savePath, "${chapter.title}\n$content");
    onSuccess?.call(savePath);
  }

  /// 下载章节内容
  /// [bookChapter] 章节信息
  downloadChapterTxt(BookChapter chapter,
      {OnStart? onStart,
      OnProgress? onProgress,
      OnSuccess? onSuccess,
      OnFailure? onFailure}) async {
    // String savePath =
    //     "${(await FileService.externalDir())}/${chapter.title}_${chapter.index}.txt";
    String savePath =
        "${await localDir(chapter.bookId)}/${chapter.title}_${chapter.index}.txt";
    String? url = chapter.url;
    if (url == null || url.isEmpty) {
      onFailure?.call(-1, "下载地址不能为空", savePath ?? "");
      return;
    }
    BookUrl bookUrl = BookUrl.fromJson(jsonDecode(chapter.url!));
    String? urlPath = bookUrl.path;
    if (urlPath == null) {
      onFailure?.call(-1, "无法解析到下载地址", savePath);
      return;
    }
    UrlKeys keys = UrlKeys();
    DownloadRequest request = DownloadRequest(urlPath, savePath,
        queryParameters: keys.combine(bookUrl.params),
        options: dio.Options(method: bookUrl.method ?? "GET"));
    downloadManager.download(request, onStart: onStart, onProgress: onProgress,
        onSuccess: (savePath) {
      chapter.localPath = savePath;
      bookRepository.insertOrUpdateChapter(chapter).whenComplete(() {
        onSuccess?.call(savePath);
      });
    }, onFailure: onFailure);
  }


  Future<String> localDir(String bookId) async {
    return "${await FileService.externalDir()}/${Utils.md5Str(bookId)}/";
  }
}
