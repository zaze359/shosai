import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  String? initialValue;
  InputDecoration? decoration;
  ValueChanged<String>? onChanged;
  FormFieldValidator<String>? validator;

  MyTextFormField(
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
