import 'package:shosai/core/common/di.dart';
import 'package:shosai/core/data/model/book_model.dart';
import 'package:shosai/core/database/model/book_entity.dart';
import 'package:shosai/core/model/book.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/core/database/dao/book_dao.dart';

/// 书籍相关数据库
abstract class BookRepository {

  /// 新增或更新书籍信息
  Future<int> insertOrUpdateBook(Book book);

  /// 删除书籍
  Future<int> deleteBook(Book book);

  /// 删除书籍
  Future<List<BookEntity>> queryBook(String bookId);

  /// 查询所有书籍
  Future<List<Book>> queryAllBooks();

  // --------------------------------------------------
  /// 新增或更新章节信息
  Future<int> insertOrUpdateChapter(BookChapter chapter);

  /// 插入或更新章节信息
  Future<List<Object?>> insertChapters(List<BookChapter> chapters);

  /// 查询指定书籍的章节信息
  Future<List<BookChapter>> queryBookChapters(String bookId);

  /// 清除指定书籍的章节信息
  Future<int> clearBookChapters(String bookId);
  // --------------------------------------------------
  Future<int> updateBookSource(BookSource? source);

  Future<List<Object?>> insertBookSources(List<BookSource> sources);

  Future<BookSource?> queryBookSource(String url);

  /// 获取所有书源列表
  Future<List<BookSource>> queryAllBookSources();
}

class BookRepositoryImpl extends BookRepository{
  BookRepositoryImpl(this._bookDao);

  final BookDao _bookDao;
  @override
  Future<int> insertOrUpdateBook(Book book) async {
    return _bookDao.insertOrUpdateBook(book.bookAsEntity());
  }

  @override
  Future<int> deleteBook(Book book) async {
    await clearBookChapters(book.id);
    return _bookDao.deleteBook(book.id);
  }

  @override
  Future<List<BookEntity>> queryBook(String bookId) async {
    return _bookDao.queryBook(bookId);
  }

  @override
  Future<List<Book>> queryAllBooks() async {
    return _bookDao
        .queryAllBooks()
        .then((value) => value.map(bookEntityAsExternalModel).toList());
  }

  @override
  Future<int> insertOrUpdateChapter(BookChapter chapter) async {
    return _bookDao.insertOrUpdateChapter(chapterAsEntity(chapter));
  }

  @override
  Future<List<Object?>> insertChapters(List<BookChapter> chapters) async {
    return _bookDao
        .insertChapters(chapters.map(chapterAsEntity).toList());
  }

  @override
  Future<List<BookChapter>> queryBookChapters(String bookId) async {
    return _bookDao
        .queryBookChapters(bookId)
        .then((value) => value.map(chapterEntityAsExternalModel).toList());
  }

  @override
  Future<int> clearBookChapters(String bookId) async {
    return _bookDao.clearBookChapters(bookId);
  }

  @override
  Future<int> updateBookSource(BookSource? source) async {
    if (source == null) {
      return 0;
    }
    return _bookDao.updateBookSource(source);
  }

  @override
  Future<List<Object?>> insertBookSources(List<BookSource> sources) async {
    return _bookDao.insertBookSources(sources);
  }

  @override
  Future<BookSource?> queryBookSource(String url) async {
    return _bookDao.queryBookSource(url);
  }

  @override
  Future<List<BookSource>> queryAllBookSources() async {
    return _bookDao.queryAllBookSources();
  }
}
