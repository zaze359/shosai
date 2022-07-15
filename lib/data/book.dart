import 'dart:io';
import 'package:path/path.dart' as path;

/// Description : 书籍
/// @author zaze
/// @date 2022/6/5 - 13:03
class Book {
  /// 数据库id, file Uri
  String id;

  /// 书名
  String? name;

  /// 书籍的本地存储路径。
  String? localPath;

  /// 来源， 默认本地
  String origin = "";

  /// 文件后缀
  String? extension;

  /// 编码格式
  String? charset;

  /// 简介
  String? intro;

  /// 最近访问时间 ms
  int latestVisitTime = 0;

  /// 书籍导入时间ms
  int importTime = 0;

  /// 作者
  String? author;

  /// 标签  ,分割
  String? tags;

  /// 字数
  String? wordCount;

  /// 更新时间
  String? updateTime;

  /// 最后一章
  String? latestChapterTitle;

  /// 封面地址
  String? coverUrl;

  /// 目录地址
  String? tocUrl;

  /// 最近检测时间;
  int latestCheckTime = 0;

  Book({
    required this.id,
    this.name = "",
    this.extension = "",
    this.localPath = "",
  });

  Book.formFile(File file)
      : id = file.uri.toString(),
        name = path.basenameWithoutExtension(file.path),
        extension = path.extension(file.path),
        localPath = file.path,
        importTime = DateTime.now().millisecondsSinceEpoch;

  Book.fromMap(Map<String, dynamic> map) : id = map['id'] {
    name = map['name'];
    extension = map['extension'];
    localPath = map['localPath'];
    charset = map['charset'];
    intro = map['intro'];
    latestVisitTime = map['latestVisitTime'] ?? 0;
    importTime = map['importTime'] ?? 0;
    author = map['author'];
    tags = map['tags'];
    wordCount = map['wordCount'];
    updateTime = map['updateTime'];
    latestChapterTitle = map['latestChapterTitle'];
    latestCheckTime = map['latestCheckTime'] ?? 0;
    coverUrl = map['coverUrl'];
    tocUrl = map['tocUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'extension': extension,
      'localPath': localPath,
      'charset': charset,
      'intro': intro,
      'latestVisitTime': latestVisitTime,
      'importTime': importTime,
      'author': author,
      'tags': tags,
      'wordCount': wordCount,
      'updateTime': updateTime,
      'latestChapterTitle': latestChapterTitle,
      'latestCheckTime': latestCheckTime,
      'coverUrl': coverUrl,
      'tocUrl': tocUrl,
    };
  }

  bool isLocal() {
    return origin.isEmpty;
  }
  @override
  String toString() => '''
  书籍信息:
  -------------------
  ID: $id
  书名: $name
  作者: $author
  标签: $tags
  简介: $intro
  字数: $wordCount
  最新章节: $latestChapterTitle
  更新时间: $updateTime
  封面地址: $coverUrl
  目录列表: $tocUrl
  来源: $origin
  本地存储地址: $localPath
  文件后缀: $extension
  字符编码: $charset
  导入时间: $importTime
  最近访问时间: $latestVisitTime
  最近检测时间: $latestCheckTime
  -------------------
  ''';
}

/// 书的章节
class BookChapter {
  /// Book url
  String bookId;

  /// 章节地址 BookUrl
  String? url;

  /// 章节位置
  int index;

  /// 章节标题
  String title;

  /// 章节从文本的第几个字节开始
  int charStart;

  /// 章节从文本的到第几个字节结束
  int charEnd;

  BookChapter(
      {required this.bookId,
      required this.index,
      required this.title,
      this.url,
      this.charStart = 0,
      this.charEnd = 0});

  void reset(
      {required int index, required String title, required int charStart}) {
    this.title = title;
    this.index = index;
    this.charStart = charStart;
    charEnd = charStart;
  }

  BookChapter fork() {
    return BookChapter(
      bookId: bookId,
      index: index,
      title: title,
      charStart: charStart,
      charEnd: charEnd,
    );
  }

  @override
  String toString() {
    return 'BookChapter{bookUrl: $bookId, url: $url, index: $index, title: $title, charStart: $charStart, charEnd: $charEnd}';
  }
}
