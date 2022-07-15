import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  ValueChanged<String>? onSubmitted;

  String? hintText;
  bool enabled = true;

  TextEditingController? controller;

  SearchBar(
      {Key? key,
      this.hintText,
      this.onSubmitted,
      this.enabled = true,
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSubmitted?.call("");
      },
      child: Container(
        // alignment: Alignment.center,
        height: 36,
        // padding: EdgeInsets.fromLTRB(4, 0, 4, 0),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          autofocus: true,
          maxLines: 1,
          minLines: 1,
          enabled: enabled,
          controller: controller,
          onEditingComplete: () {
            print("onEditingComplete");
          },
          onFieldSubmitted: onSubmitted,
          onSaved: (v) {
            print("onSaved $v");
          },
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          // textAlign: TextAlign.start,
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            contentPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
            // constraints: BoxConstraints(),
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            // prefixIcon: TextButton(
            //   style: ButtonStyle(
            //     overlayColor: MaterialStateColor.resolveWith((states) {
            //       return Colors.white10;
            //     }),
            //   ),
            //   onPressed: null,
            //   child: const Icon(
            //     Icons.search,
            //     color: Colors.white,
            //   ),
            // ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (v) {
            print("onChanged $v");
          },
        ),
      ),
    );
  }
}
