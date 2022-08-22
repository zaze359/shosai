
import 'dart:convert';

import 'package:shosai/utils/utils.dart';

void main() {
  String content = "{\"path\":\"http://www.1222.com/123/\",\"method\":\"GET\",\"params\":[],\"body\":[]}";
  print("md5 test 1: ${Utils.md5(utf8.encode(content))}");
  print("md5 test 2: ${Utils.md5Str(content)}");
}