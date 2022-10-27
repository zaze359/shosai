
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/service/spider/spider.dart';
import 'package:shosai/widgets/request_args_layout.dart';
import 'package:shosai/widgets/text_form_field.dart';

/// 书源搜索规则组件编辑页
class SearchRuleEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        SearchRule rule = bookSource.searchRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "搜索地址",
                    hintText: "相对或绝对路径",
                  ),
                  initialValue: bookSource.searchUrl.path ?? "",
                  onChanged: (value) {
                    bookSource.searchUrl.path = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书籍列表规则",
                  ),
                  initialValue: rule.bookList.rule ?? "",
                  onChanged: (value) {
                    rule.bookList.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "书名规则",
                  ),
                  initialValue: rule.name.rule ?? "",
                  onChanged: (value) {
                    rule.name.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "作者规则",
                  ),
                  initialValue: rule.author.rule ?? "",
                  onChanged: (value) {
                    rule.author.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "封面规则",
                  ),
                  initialValue: rule.coverUrl.rule ?? "",
                  onChanged: (value) {
                    rule.coverUrl.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "简介规则",
                  ),
                  initialValue: rule.intro.rule ?? "",
                  onChanged: (value) {
                    rule.intro.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "分类规则",
                  ),
                  initialValue: rule.tags.rule ?? "",
                  onChanged: (value) {
                    rule.tags.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "字数规则",
                  ),
                  initialValue: rule.wordCount.rule ?? "",
                  onChanged: (value) {
                    rule.wordCount.rule = value;
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
