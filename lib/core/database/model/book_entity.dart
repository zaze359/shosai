/// Description : 书籍
/// @author zaze
/// @date 2022/6/5 - 13:03
class BookEntity {
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

  BookEntity(this.id,
      {this.name,
      this.localPath,
      this.origin = "",
      this.extension,
      this.charset,
      this.intro,
      this.latestVisitTime = 0,
      this.importTime = 0,
      this.author,
      this.tags,
      this.wordCount,
      this.updateTime,
      this.latestChapterTitle,
      this.coverUrl,
      this.tocUrl,
      this.latestCheckTime = 0});
}

/// 书的章节
class BookChapterEntity {
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

  /// 若是远程加载的，这个是每个章节本地存储路径
  String? localPath;

  BookChapterEntity(
      {required this.bookId,
      required this.index,
      required this.title,
      required this.url,
      required this.charStart,
      required this.charEnd,
      required this.localPath});
}
