import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/utils/http.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/request_args_layout.dart';

class _SpiderMode extends ChangeNotifier {
  BookSource bookSource;
  UrlKeys searchKeys = UrlKeys("");

  TextStyle inputTextStyle = const TextStyle(fontSize: 18, color: Colors.white);

  _SpiderMode(this.bookSource);

  addParam(UrlParam param) {
    bookSource.searchUrl.params.add(param);
    printD("addParam: $param");
  }

  updateSearchKey(String key) {
    searchKeys.key = key;
  }

  startSearch() {
    if (searchKeys.isEmpty()) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: "请输入搜索关键字",
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 18.0,
      );
    } else {
      httpHelper.search(bookSource, searchKeys);
    }
  }
}

/// 书籍爬虫工具
class SpiderPage extends StatelessWidget {
  SpiderPage({Key? key}) : super(key: key);

  TextStyle tabStyle = const TextStyle(fontSize: 18, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    Map<Widget, Widget> tabMap = {
      Text(
        "基本",
        style: tabStyle,
      ): _BookSourceInfo(),
      Text(
        "搜索",
        style: tabStyle,
      ): _BookSearchInfo()
    };
    BookSource? bookSource =
        ModalRoute.of(context)?.settings.arguments as BookSource?;
    if (bookSource == null) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("测试书源解析"),
          ),
          body: Text(""));
    }
    //            Theme(
    // data: ThemeData(
    // brightness: Brightness.dark,
    // primaryColor: Colors.red,
    // selectedRowColor: Colors.red,
    // iconTheme: const IconThemeData(color: Colors.teal),
    // ),)
    return ChangeNotifierProvider(
      create: (_) {
        return _SpiderMode(bookSource);
      },
      builder: (context, _) {
        return DefaultTabController(
          length: tabMap.length,
          child: Scaffold(
            appBar: AppBar(
              title: Container(
                // alignment: Alignment.center,
                height: 36,
                // padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: buildSearchBar(context),
              ),
              actions: [
                IconButton(
                  tooltip: MaterialLocalizations.of(context).searchFieldLabel,
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  onPressed: () {
                    BookRepository().updateBookSource(bookSource);
                  },
                ),
              ],
              bottom: TabBar(
                tabs: tabMap.keys.toList(),
              ),
            ),
            body: TabBarView(
              children: tabMap.values.toList(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<_SpiderMode>().startSearch();
              },
              child: Icon(Icons.play_arrow),
            ),
          ),
        );
      },
    );
  }

  buildSearchBar(BuildContext context) {
    return TextField(
      autofocus: true,
      maxLines: 1,
      minLines: 1,
      // textAlign: TextAlign.start,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: "书名",
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        contentPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        // constraints: BoxConstraints(),
        suffixIcon: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith((states) {
              return Colors.white10;
            }),
          ),
          onPressed: () {
            context.read<_SpiderMode>().startSearch();
          },
          child: const Icon(
            Icons.search,
            color: Colors.white,
          ),
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (v) {
        context.read<_SpiderMode>().updateSearchKey(v);
      },
    );
  }
}

// 书源信息
class _BookSourceInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "地址",
                    hintText: "https://www.xxx.com",
                  ),
                  initialValue: bookSource.url,
                  validator: (value) {
                    return value!.trim().isNotEmpty ? null : "书源地址不能为空";
                  },
                  onChanged: (value) {
                    bookSource.url = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "名称",
                  ),
                  initialValue: bookSource.name,
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "书源名称不能为空";
                  },
                  onChanged: (value) {
                    bookSource.name = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "描述",
                  ),
                  initialValue: bookSource.comment,
                  onChanged: (value) {
                    bookSource.comment = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "分组",
                    hintText: "玄幻",
                  ),
                  initialValue: bookSource.tags,
                  onChanged: (value) {
                    bookSource.tags = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookSearchInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<_SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        SearchRule searchRule = bookSource.searchRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "搜索地址",
                    hintText: "相对或绝对路径",
                  ),
                  initialValue: bookSource.searchUrl.path ?? "",
                  onChanged: (value) {
                    bookSource.searchUrl.path = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书籍列表规则",
                  ),
                  initialValue: searchRule.bookList.rule ?? "",
                  onChanged: (value) {
                    searchRule.bookList.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书名规则",
                  ),
                  initialValue: searchRule.name.rule ?? "",
                  onChanged: (value) {
                    searchRule.name.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "作者规则",
                  ),
                  initialValue: searchRule.author.rule ?? "",
                  onChanged: (value) {
                    searchRule.author.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "封面规则",
                  ),
                  initialValue: searchRule.coverUrl.rule ?? "",
                  onChanged: (value) {
                    searchRule.coverUrl.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "简介规则",
                  ),
                  initialValue: searchRule.intro.rule ?? "",
                  onChanged: (value) {
                    searchRule.intro.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "分类规则",
                  ),
                  initialValue: searchRule.tags.rule ?? "",
                  onChanged: (value) {
                    searchRule.tags.rule = value;
                  },
                ),
                _MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "字数规则",
                  ),
                  initialValue: searchRule.wordCount.rule ?? "",
                  onChanged: (value) {
                    searchRule.wordCount.rule = value;
                  },
                ),
                RequestArgsWidget(bookSource.searchUrl.params, mode.addParam),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MyTextFormField extends StatelessWidget {
  String? initialValue;
  InputDecoration? decoration;
  ValueChanged<String>? onChanged;
  FormFieldValidator<String>? validator;

  _MyTextFormField(
      {this.initialValue, this.decoration, this.onChanged, this.validator});

  // ?.characters.join('\u{200B}')
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
      maxLines: 10,
      minLines: 1,
      decoration: InputDecoration(
        labelText: decoration?.labelText,
        labelStyle: const TextStyle(color: Colors.red),
        hintText: decoration?.hintText,
        hintStyle: decoration?.hintStyle,
        hintMaxLines: decoration?.hintMaxLines,
      ),
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
