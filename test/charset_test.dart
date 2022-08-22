import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:charset/charset.dart';
import 'package:shosai/utils/charsets.dart';
import 'package:shosai/utils/file_util.dart';
import 'package:shosai/utils/utils.dart';

void main() async {
  List<int> chars = [
    0xA1,
    0xA1,
    0xB7,
    0xA8,
    0xC0,
    0xBC,
    0xCA,
    0xAB,
    0xB1,
    0xA6,
    0xB8,
    0xDF,
    0xBC,
    0xB6,
    0xC3,
    0xC0
  ];
  String decoded = gbk.decode(chars);
  print("decoded: $decoded");
  print("gbk: ${Charset.canDecode(gbk, chars)} :${gbk.decode(chars)}");
  print("utf8: ${Charset.canDecode(utf8, chars)}");
  print("utf16: ${Charset.canDecode(utf16, chars)}: ${utf16.decode(chars)}");
  print("utf32: ${Charset.canDecode(utf32, chars)}");
  print("matchCharset: ${File("test/chars.txt").absolute.path}");
  Stream<List<int>> stream = FileService.openRead("test/chars.txt");
  chars.clear();
  await for (var e in stream) {
    chars.addAll(e);
  }

  ///
  print("matchCharset: ${chars.length}, ${CharsetCodec.matchCharset(chars)}");
}

Uint8List toUint8List(List<int> input) {
  if (input is Uint8List) return input;
  if (input is TypedData) {
    // TODO(nweiz): remove "as" when issue 11080 is fixed.
    return Uint8List.view((input as TypedData).buffer);
  }
  return Uint8List.fromList(input);
}
