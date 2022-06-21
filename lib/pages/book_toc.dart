import 'package:flutter/material.dart';
import 'package:shosai/data/book.dart';
import 'package:shosai/utils/controller.dart';
import 'package:shosai/utils/custom_event.dart';
import 'package:shosai/utils/log.dart';

class BookTocPage extends StatelessWidget {
  BookTocPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('目录'),
      ),
      body: BookTocWidget(bookController.getBookChapters(),
          bookController.chapterIndex),
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
