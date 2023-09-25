import 'package:flutter/material.dart';
import 'package:shosai/core/common/di.dart';
import 'package:shosai/core/data/repository/book_repository.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/utils/rule_convert.dart';

/// Description : 书源页
/// @author zaze
/// @date 2022/8/23 - 3:52
class BookSourcePage extends StatefulWidget {
  const BookSourcePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BookSourcePageState();
  }
}

class _BookSourcePageState extends State<BookSourcePage> {
  BookRepository bookRepository = Injector.instance.get<BookRepository>();

  @override
  Widget build(BuildContext context) {
    printD("_BookSourcePageState : Build");
    return Scaffold(
      appBar: AppBar(
        title: const Text("书源"),
      ),
      body: FutureBuilder<List<BookSource>>(
        future: bookRepository.queryAllBookSources(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "${snapshot.error} ${snapshot.stackTrace}",
                ),
              );
            }
            List<BookSource> data = snapshot.data ?? [];
            printD("data: ${snapshot.data}");
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: data.length,
                itemExtent: 48,
                itemBuilder: (c, index) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        AppRoutes.startSpiderPage(context, data[index]);
                      },
                      style: TextButton.styleFrom(
                        surfaceTintColor: Colors.black,
                        minimumSize:
                            const Size(double.infinity, double.infinity),
                        side: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                            style: BorderStyle.solid),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      child: Text(
                        data[index].name,
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Text("加载中"),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ConvertRule().formLegadoJson("");
          setState(() {});
        },
        child: Icon(Icons.transform),
      ),
    );
  }
}
