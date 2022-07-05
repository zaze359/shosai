import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shosai/utils/log.dart';
import 'package:html/dom.dart';

part 'book_source.g.dart';

/// 书源
@JsonSerializable()
class BookSource {
  /// 书源url
  String url;

  /// 书源名
  String name;

  /// 分组
  String? tags;

  /// 描述
  String? comment;

  /// 搜索url
  BookUrl searchUrl = BookUrl();

  // 搜索规则
  SearchRule searchRule = SearchRule();

  // 最近更新时间
  int lastUpdateTime = 0;

  BookSource({this.url = "", this.name = ""})
      : lastUpdateTime = DateTime.now().millisecondsSinceEpoch;

  static List<BookSource> fromJsonArray(List<dynamic> jsonArray) {
    List<BookSource> list = [];
    for (var element in jsonArray) {
      list.add(BookSource.fromJson(element));
    }
    return list;
  }

  factory BookSource.fromJson(Map<String, dynamic> json) =>
      _$BookSourceFromJson(json);

  Map<String, dynamic> toJson() => _$BookSourceToJson(this);

  BookSource.fromMap(Map<String, dynamic> map)
      : url = map['url'],
        name = map['name'],
        tags = map['tags'],
        comment = map['comment'] {
    searchUrl = BookUrl.fromJson(jsonDecode(map['searchUrl']));
    searchRule = SearchRule.fromJson(jsonDecode(map['searchRule']));
    lastUpdateTime = map['lastUpdateTime'] ?? 0;
  }

  Map<String, dynamic> toMap() => {
        'url': url,
        'name': name,
        'tags': tags,
        'comment': comment,
        'searchUrl': jsonEncode(searchUrl),
        'searchRule': jsonEncode(searchRule),
        'lastUpdateTime': lastUpdateTime,
      };

  @override
  String toString() {
    return 'BookSource{url: $url, name: $name, tags: $tags, comment: $comment, searchUrl: $searchUrl, searchRule: $searchRule}';
  }
}

@JsonSerializable()
class BookUrl {
  String? path;
  String? method;
  List<UrlParam> params = [];
  List<UrlParam> body = [];

  BookUrl({this.path, this.method = "GET"});

  factory BookUrl.fromJson(Map<String, dynamic> json) =>
      _$BookUrlFromJson(json);

  Map<String, dynamic> toJson() => _$BookUrlToJson(this);

  @override
  String toString() {
    return '{path: $path, method: $method, params: $params, body: $body}';
  }
}

@JsonSerializable()
class UrlParam {
  String key;
  ParamValue value;

  UrlParam(this.key, this.value);

  UrlParam.fromKV(this.key, String v) : value = ParamValue(v);

  factory UrlParam.fromJson(Map<String, dynamic> json) =>
      _$UrlParamFromJson(json);

  Map<String, dynamic> toJson() => _$UrlParamToJson(this);

  static List<UrlParam> fromParamStr(String urlParamStr) {
    List<UrlParam> list = [];
    urlParamStr.split("&").forEach((element) {
      var kv = element.split("=");
      if (kv.length == 2) {
        list.add(UrlParam(kv[0], ParamValue(kv[1])));
      }
    });
    return list;
  }

  @override
  String toString() {
    return '{key: $key, value: $value}';
  }
}

@JsonSerializable()
class ParamValue {
  String value;

  /// TODO 加密方式
  /// 多种加密方式 已 , 分割；加密顺序为从前到后。
  String? encrypt;

  ParamValue(this.value);

  factory ParamValue.fromJson(Map<String, dynamic> json) =>
      _$ParamValueFromJson(json);

  Map<String, dynamic> toJson() => _$ParamValueToJson(this);

  @override
  String toString() {
    return '{value: $value, encrypt: $encrypt}';
  }
}

class UrlKeys {
  final Map<String, dynamic> _params = {};

  set key(String key) {
    _params["{{key}}"] = key;
  }

  set page(int page) {
    _params["{{page}}"] = page;
  }

  UrlKeys(String key, {int page = 1}) {
    this.key = key;
    this.page = page;
  }

  bool isEmpty() {
    return _params["{{key}}"].toString().isEmpty;
  }

  /// 搜索url中的关键字：可配参数
  /// https://www.bilibili.com/?page=1&searchkey={未知的关键字}
  /// key = 'searchkey'
  /// value = '${key}' ； 这里的值需要在SearchKeys中已申明才实际可用
  Map<String, dynamic>? combine(List<UrlParam>? params) {
    if (params == null) {
      return null;
    }
    Map<String, dynamic> newMap = {};
    for (UrlParam param in params) {
      // newMap[param.key] = param.value.value;
      String value = param.value.value;
      if (value.startsWith('{{') && value.endsWith('}}')) {
        newMap[param.key] = _params[value];
      } else {
        newMap[param.key] = value;
      }
    }
    return newMap;
  }

  @override
  String toString() {
    return 'SearchKeys{_params: $_params}';
  }
}

class SearchRule {
  // 书籍列表
  BookRule bookList = BookRule(ruleName: "书籍列表");

  // 书籍名
  BookRule name = BookRule(ruleName: "书籍名");

  // 作者
  BookRule author = BookRule(ruleName: "作者");

  // 简介
  BookRule intro = BookRule(ruleName: "简介");

  // 类型
  BookRule tags = BookRule(ruleName: "类型");

  // 最新章节
  BookRule latestChapter = BookRule(ruleName: "最新章节");

  // 更新时间
  BookRule updateTime = BookRule(ruleName: "更新时间");

  // 书籍详情页
  BookRule bookUrl = BookRule(ruleName: "书籍详情页");

  // 封面
  BookRule coverUrl = BookRule(ruleName: "封面");

  // 字数
  BookRule wordCount = BookRule(ruleName: "字数");

  SearchRule();

  SearchRule.fromJson(dynamic json) {
    Map jsonObj;
    if (json is Map) {
      jsonObj = json;
    } else {
      jsonObj = jsonDecode(json);
    }
    bookList.rule = jsonObj["bookList"];
    name.rule = jsonObj["name"];
    author.rule = jsonObj["author"];
    intro.rule = jsonObj["intro"];
    tags.rule = jsonObj["tags"];
    latestChapter.rule = jsonObj["latestChapter"];
    updateTime.rule = jsonObj["updateTime"];
    bookUrl.rule = jsonObj["bookUrl"];
    coverUrl.rule = jsonObj["coverUrl"];
    wordCount.rule = jsonObj["wordCount"];
  }

  Map<String, dynamic> toJson() {
    return {
      "bookList": bookList.rule,
      "name": name.rule,
      "author": author.rule,
      "intro": intro.rule,
      "tags": tags.rule,
      "latestChapter": latestChapter.rule,
      "updateTime": updateTime.rule,
      "bookUrl": bookUrl.rule,
      "coverUrl": coverUrl.rule,
      "wordCount": wordCount.rule,
    };
  }

  @override
  String toString() {
    return 'SearchRule{bookList: $bookList, name: $name, author: $author, intro: $intro, tags: $tags, latestChapter: $latestChapter, updateTime: $updateTime, bookUrl: $bookUrl, coverUrl: $coverUrl, wordCount: $wordCount}';
  }
}

class BookRule {
  String? rule;
  String? ruleName;

  BookRule({this.rule, this.ruleName});

  @override
  String toString() {
    return '$rule';
  }

  String getResult(dynamic element,
      {String separator = "", Pattern? from, String? replace}) {
    List<Element>? list = getElements(element);
    if (list == null || list.isEmpty) {
      return "";
    }
    String result = list.map((e) {
      return e.text;
    }).where((element) {
      return element.isNotEmpty;
    }).join(separator);
    return result.replaceAll(from ?? RegExp(r'[\s]+'), replace ?? "");
  }
  // a@[[0]]@#p@href@###.+\D((\d+)\d{3})\D##https://www.xbiquwx.la/files/article/image/$2/$1/$1s.jpg###
  List<Element>? getElements(dynamic element) {
    if (element is Element || element is Document) {
      List<String>? array = rule?.split("@");
      if (array == null) {
        return null;
      }
      bookSourceLog(" ----------------- BookRule start $ruleName: $rule");
      var css = array[0];
      List<Element> queryElements = element.querySelectorAll(css);
      bookSourceLog("BookRule css: $css; ${queryElements.map((e) {
        return e.outerHtml;
      }).join("\n")}");
      if (array.length == 1) {
        return queryElements;
      }
      array.sublist(1, array.length).forEach((cmd) {
        queryElements = _execute(queryElements, cmd.trim());
      });
      bookSourceLog(
          "BookRule elements : ${queryElements.map((e) {
        return e.outerHtml;
      }).join(" ")}");
      bookSourceLog(" ----------------- BookRule end $ruleName: $rule");
      return queryElements;
    }
    return null;
  }

  List<Element> _execute(List<Element> elements, String rule) {
    if (rule.isEmpty) {
      // 空字符，不处理
      return elements;
    }
    if (rule.startsWith('[[') && rule.endsWith(']]')) {
      // 位置区间相关规则处理
      return _executeIndex(elements, rule.substring(2, rule.length - 2));
    } else if (rule.startsWith('###') && rule.endsWith('###')) {
      // 将前面匹配到的内容进行正则替换
      rule = rule.replaceAll("###", "");
      return _executeRegExp(elements, rule);
    } else if (rule.startsWith('\$')) {
      // 属性获取
      rule = rule.substring(1, rule.length);
      return _executeAttributes(elements, rule);
    } else {
      return _executeSelector(elements, rule);
    }
  }

  /// Selector相关规则
  List<Element> _executeSelector(List<Element> elements, String rule) {
    bookSourceLog("BookRule _executeSelector: $rule");
    List<Element> result = [];
    for (var element in elements) {
      result.addAll(element.querySelectorAll(rule));
    }
    return result;
  }

  /// 属性相关规则
  List<Element> _executeAttributes(List<Element> elements, String rule) {
    bookSourceLog("BookRule _executeAttributes: $rule; ${elements.length}");
    switch (rule) {
      case "text":
        break;
      case "href":
        elements = _findAttributes(elements, rule);
        break;
      default:
        elements = _executeSelector(elements, rule);
        break;
    }
    return elements;
  }

  /// 查询指定 attr 的内容。
  /// 将 attribute的内容放到element的text中。
  List<Element> _findAttributes(List<Element> elements, String attr) {
    List<Element> result = [];
    for (var element in elements) {
      print("BookRule _findAttributes $attr : ${element.outerHtml}");
      element.attributes.forEach((k, v) {
        if (k == attr) {
          Element e = Element.tag(element.localName);
          e.text = v;
          bookSourceLog("BookRule _findAttributes: $k=$v >> ${e.text}");
          result.add(e);
          return;
        }
      });
    }
    return result;
  }

  /// 执行位置相关规则
  List<Element> _executeIndex(List<Element> elements, String rule) {
    bookSourceLog("BookRule _executeIndex: $rule");
    if (elements.isEmpty) {
      return elements;
    }
    List<int> selectedIndex = [];
    bool isRemove = false;
    if (rule.contains('!')) {
      isRemove = true;
      rule = rule.substring(1, rule.length);
    }
    if (rule.contains('..')) {
      // 连续数组
      var sAe = rule.split("..");
      int start = int.parse(sAe[0]);
      if (start < 0) {
        start = start + elements.length;
      }
      int end = int.parse(sAe[1]);
      if (end < 0) {
        end = end + elements.length;
      }
      if (start > end) {
        for (int i = start; i <= end; i++) {
          selectedIndex.add(i);
        }
      } else {
        for (int i = end; i <= start; i--) {
          selectedIndex.add(i);
        }
      }
    } else {
      // 单独选择的位置
      int index = int.parse(rule);
      selectedIndex.add(index >= 0 ? index : (elements.length + index));
    }
    if (isRemove) {
      for (var index in selectedIndex) {
        elements.removeAt(index);
      }
      return elements;
    } else {
      List<Element> resultList = [];
      for (var index in selectedIndex) {
        resultList.add(elements[index]);
      }
      return resultList;
    }
  }

  // 处理替换规则
  List<Element> _executeRegExp(List<Element> elements, String rule) {
    bookSourceLog("BookRule _executeRegExp: $rule; ${elements.length}");
    var list = rule.split("##");
    if (list.length < 2) {
      for (var element in elements) {
        element.text = element.text.replaceAll(list[0], "");
      }
      return elements;
    }
    RegExp regExp = RegExp(list[0]);
    String content = list[1];
    for (var element in elements) {
      // bookSourceLog("BookRule regExp: $regExp");
      Iterable<Match> matchers = regExp.allMatches(element.text);
      for (var match in matchers) {
        for (int i = 0; i <= match.groupCount; i++) {
          // bookSourceLog("BookRule match: ${match.group(i)}");
          // 将对应到内容填充到相应位置。
          content = content.replaceAll("\$$i", "${match.group(i)}");
        }
      }
      element.text = content;
    }
    return elements;
  }
}

class RuleWrapper {}
