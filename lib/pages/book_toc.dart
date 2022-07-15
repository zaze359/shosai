import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/utils/controller.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';

class BookTocPage extends StatelessWidget {
  BookTocPage({super.key});

  Future<List<BookChapter>> loadBookChapters(Book? book) async {
    bookController.book = book;
    if (book?.isLocal() == false) {
      await bookController.init();
    }
    return bookController.getBookChapters();
  }

  @override
  Widget build(BuildContext context) {
    Book? book = ModalRoute.of(context)?.settings.arguments as Book?;
    return Scaffold(
      appBar: AppBar(
        title: const Text('目录'),
      ),
      body: LoadingBuild<List<BookChapter>>(
        future: loadBookChapters(book),
        success: (c, v) {
          return BookTocWidget(
            v ?? [],
            bookController.chapterIndex,
          );
        },
      ),
    );
  }
}

/// 书籍目录页
class BookTocWidget extends StatefulWidget {
  BookTocWidget(this._chapters, this._selectedIndex, {super.key});

  final int _selectedIndex;
  final List<BookChapter> _chapters;
  TextStyle selectedStyle = const TextStyle(color: Colors.redAccent);
  TextStyle unselectedStyle = const TextStyle(color: Colors.black);

  @override
  State<StatefulWidget> createState() {
    return BookTocWidgetState();
  }
}

class BookTocWidgetState extends State<BookTocWidget> {
  final double _widgetHeight = 50;
  late ScrollController controller = ScrollController(
      initialScrollOffset: widget._selectedIndex * _widgetHeight);

  @override
  Widget build(BuildContext context) {
    printD("BookTocWidget", "_selectedIndex: ${widget._selectedIndex}");
    return ListView.builder(
      itemCount: widget._chapters.length,
      itemExtent: _widgetHeight,
      controller: controller,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            bookController.moveToChapter(index);
            eventBus.fire(ReadEvent(index));
            Navigator.pop(context);
          },
          child: ListTile(
            title: Text(widget._chapters[index].title,
                style: index == widget._selectedIndex
                    ? widget.selectedStyle
                    : widget.unselectedStyle),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    controller.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
