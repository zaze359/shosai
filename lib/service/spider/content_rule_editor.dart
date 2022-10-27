
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/service/spider/spider.dart';
import 'package:shosai/widgets/text_form_field.dart';

/// 正文
class ContentRuleEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        ContentRule rule = bookSource.contentRule;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "正文规则",
                  ),
                  initialValue: rule.content.rule ?? "",
                  onChanged: (value) {
                    rule.content.rule = value;
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
