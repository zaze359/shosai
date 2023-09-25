import 'package:event_bus/event_bus.dart';
import 'package:shosai/core/model/book.dart';

EventBus eventBus = EventBus();

class ReadEvent {
  int chapterIndex;

  ReadEvent(this.chapterIndex);
}

class BookEvent {
  Book book;

  /// 0: add
  /// 1: delete
  int flag;

  BookEvent.addBook(this.book) : flag = 0;

  BookEvent.removeBook(this.book) : flag = 1;

  bool isAdd() {
    return flag == 0;
  }

  bool isDelete() {
    return flag == 1;
  }
}
