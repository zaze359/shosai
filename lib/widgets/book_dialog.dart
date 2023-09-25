import 'package:flutter/material.dart';
import 'package:shosai/core/model/book.dart';

/// 书籍删除弹窗
class DeleteBookDialog extends StatelessWidget {
  DeleteBookDialog(this._book, this.deleteFunc);

  Book _book;
  bool _deleteFile = false;
  Function(bool) deleteFunc;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_book.name ?? ""),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("确认删除?"),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  "从设备上删除源文件",
                  textAlign: TextAlign.center,
                  style: TextStyle(),
                  strutStyle: StrutStyle(
                    forceStrutHeight: true,
                  ),
                ),
                StatefulBuilder(builder: (context, setState) {
                  return Checkbox(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(1.0)),
                    ),
                    value: _deleteFile,
                    onChanged: (bool? value) {
                      setState(() {
                        _deleteFile = value == true;
                      });
                    },
                  );
                }),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("取消"),
        ),
        TextButton(
          onPressed: () {
            deleteFunc(_deleteFile);
            Navigator.of(context).pop();
          },
          child: const Text("删除"),
        ),
      ],
    );
  }
}
