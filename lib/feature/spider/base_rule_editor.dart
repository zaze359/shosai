

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/feature/spider/spider_vm.dart';
import 'package:shosai/widgets/text_form_field.dart';

/// 书源基本信息规则编辑组件
class BaseRuleEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpiderMode>(
      builder: (c, mode, _) {
        BookSource bookSource = mode.bookSource;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextFormField(
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
                MyTextFormField(
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
                MyTextFormField(
                  decoration: const InputDecoration(
                    labelText: "描述",
                  ),
                  initialValue: bookSource.comment,
                  onChanged: (value) {
                    bookSource.comment = value;
                  },
                ),
                MyTextFormField(
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
