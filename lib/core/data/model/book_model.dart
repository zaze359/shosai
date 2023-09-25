import 'package:shosai/core/database/model/book_entity.dart';
import 'package:shosai/core/model/book.dart';



extension BookExt on Book {
  BookEntity bookAsEntity() {
    return BookEntity(
      id,
      name: name,
      extension: extension,
      localPath: localPath,
      origin: origin,
      charset: charset,
      intro: intro,
      latestVisitTime: latestVisitTime,
      importTime: importTime,
      author: author,
      tags: tags,
      wordCount: wordCount,
      updateTime: updateTime,
      latestChapterTitle: latestChapterTitle,
      latestCheckTime: latestCheckTime,
      coverUrl: coverUrl,
      tocUrl: tocUrl,
    );
  }
}

Book bookEntityAsExternalModel(BookEntity entity) {
  return Book(
    id: entity.id,
    name: entity.name,
    extension: entity.extension,
    localPath: entity.localPath,
    origin: entity.origin,
    charset: entity.charset,
    intro: entity.intro,
    latestVisitTime: entity.latestVisitTime,
    importTime: entity.importTime,
    author: entity.author,
    tags: entity.tags,
    wordCount: entity.wordCount,
    updateTime: entity.updateTime,
    latestChapterTitle: entity.latestChapterTitle,
    latestCheckTime: entity.latestCheckTime,
    coverUrl: entity.coverUrl,
    tocUrl: entity.tocUrl,
  );
}


BookChapterEntity chapterAsEntity(BookChapter chapter) {
  return BookChapterEntity(bookId: chapter.bookId, index: chapter.index, title: chapter.title, url: chapter.url, charStart: chapter.charStart, charEnd: chapter.charEnd, localPath: chapter.localPath);
}

BookChapter chapterEntityAsExternalModel(BookChapterEntity entity) {
  return BookChapter(
    bookId: entity.bookId,
    index: entity.index,
    title: entity.title,
    url: entity.url,
    charStart: entity.charStart,
    charEnd: entity.charEnd,
    localPath: entity.localPath,
  );
}