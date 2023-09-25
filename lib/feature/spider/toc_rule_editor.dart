
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/core/model/book_source.dart';
import 'package:shosai/feature/spider/spider_vm.dart';
import 'package:shosai/widgets/text_form_field.dart';

/// 书籍目录规则编辑页
class TocRuleEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        TocRule rule = bookSource.tocRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "目录列表规则",
                  ),
                  initialValue: rule.chapterList.rule ?? "",
                  onChanged: (value) {
                    rule.chapterList.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "章节名规则",
                  ),
                  initialValue: rule.chapterName.rule ?? "",
                  onChanged: (value) {
                    rule.chapterName.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "章节URL规则",
                  ),
                  initialValue: rule.chapterUrl.rule ?? "",
                  onChanged: (value) {
                    rule.chapterUrl.rule = value;
                  },
                ),
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "更新时间",
                  ),
                  initialValue: rule.updateTime.rule ?? "",
                  onChanged: (value) {
                    rule.updateTime.rule = value;
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
