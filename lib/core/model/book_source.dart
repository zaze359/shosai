import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart';
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

  /// 搜索规则
  SearchRule searchRule = SearchRule();

  /// 目录规则
  TocRule tocRule = TocRule();

  /// 书籍信息规则
  BookInfoRule bookInfoRule = BookInfoRule();

  /// 章节内容规则
  ContentRule contentRule = ContentRule();

  /// 最近更新时间
  int lastUpdateTime = 0;

  /// 出错次数，越大权重越低，搜索越靠后
  int errorFlag = 0;

  BookSource({this.url = "", this.name = ""})
      : lastUpdateTime = DateTime.now().millisecondsSinceEpoch;

  factory BookSource.fromJson(Map<String, dynamic> json) => _$BookSourceFromJson(json);

  /// toJson 不能放扩展中，json框架 转换时会报错。
  Map<String, dynamic> toJson() => _$BookSourceToJson(this);

  @override
  String toString() {
    return 'BookSource{url: $url, name: $name, tags: $tags, comment: $comment, errorFlag:$errorFlag, searchUrl: $searchUrl, searchRule: $searchRule, contentRule: $contentRule}';
  }
}

extension BookSourceExt on BookSource {
  static List<BookSource> fromJsonArray(List<dynamic> jsonArray) {
    List<BookSource> list = [];
    for (var element in jsonArray) {
      list.add(BookSource.fromJson(element));
    }
    return list;
  }

  void markError() {
    errorFlag++;
  }

  /// 成功，直接将 flag 减半
  /// 曾经失败过，那么最小也得是1
  void markSuccess() {
    if (errorFlag > 1) {
      errorFlag = (errorFlag / 2) as int;
    }
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

  UrlKeys({String? key, int page = 1}) {
    if (key != null) {
      this.key = key;
    }
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

@JsonSerializable()
class BookRule {
  String? rule;
  String? ruleName;

  BookRule({this.rule, this.ruleName});

  @override
  String toString() {
    return '$rule';
  }

  factory BookRule.fromJson(Map<String, dynamic> json) =>
      _$BookRuleFromJson(json);

  Map<String, dynamic> toJson() => _$BookRuleToJson(this);

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
    return result.replaceAll(from ?? RegExp(r'\s+'), replace ?? "");
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
      // $get:{h}
      List<Element> queryElements = _executeSelector([element], css);
      bookSourceLog("BookRule css: $css; ${queryElements.map((e) {
        return e.outerHtml;
      }).join("\n")}");
      if (array.length == 1) {
        return queryElements;
      }
      array.sublist(1, array.length).forEach((cmd) {
        queryElements = _execute(queryElements, cmd.trim());
      });
      bookSourceLog("BookRule elements : ${queryElements.map((e) {
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
  List<Element> _executeSelector(List<dynamic> elements, String rule) {
    bookSourceLog("BookRule _executeSelector: $rule");
    List<Element> result = [];
    for (var element in elements) {
      if (element is Element || element is Document) {
        try {
          result.addAll(element.querySelectorAll(rule));
        } catch (e) {
          bookSourceLog("BookRule _executeSelector error : $rule >> $e");
        }
      }
    }
    return result;
  }

  /// 属性相关规则
  List<Element> _executeAttributes(List<Element> elements, String rule) {
    bookSourceLog("BookRule _executeAttributes: $rule; ${elements.length}");
    switch (rule) {
      case "text":
      case "textNodes":
      case "html":
      case "all":
        break;
      case "href":
      case "src":
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
      bookSourceLog("BookRule _findAttributes $attr : ${element.outerHtml}");
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
      rule.split(':').forEach((subRule) {
        int index = int.parse(subRule);
        selectedIndex.add(index >= 0 ? index : (elements.length + index));
      });
    }
    if (isRemove) {
      for (var index in selectedIndex) {
        if (index >= elements.length) {
          continue;
        }
        elements.removeAt(index);
      }
      return elements;
    } else {
      List<Element> resultList = [];
      for (var index in selectedIndex) {
        if (index >= elements.length) {
          continue;
        }
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
    bookList.rule = json["bookList"];
    name.rule = json["name"];
    author.rule = json["author"];
    intro.rule = json["intro"];
    tags.rule = json["tags"];
    latestChapter.rule = json["latestChapter"];
    updateTime.rule = json["updateTime"];
    bookUrl.rule = json["bookUrl"];
    coverUrl.rule = json["coverUrl"];
    wordCount.rule = json["wordCount"];
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

class TocRule {
  BookRule chapterList = BookRule(ruleName: "目录列表");
  BookRule chapterName = BookRule(ruleName: "章节名");
  BookRule chapterUrl = BookRule(ruleName: "章节url");
  BookRule updateTime = BookRule(ruleName: "更新时间");

  TocRule();

  TocRule.fromJson(dynamic json) {
    chapterList.rule = json["chapterList"];
    chapterName.rule = json["chapterName"];
    chapterUrl.rule = json["chapterUrl"];
    updateTime.rule = json["updateTime"];
  }

  Map<String, dynamic> toJson() {
    return {
      "chapterList": chapterList.rule,
      "chapterName": chapterName.rule,
      "chapterUrl": chapterUrl.rule,
      "updateTime": updateTime.rule,
    };
  }

  @override
  String toString() {
    return 'TocRule{chapterList: $chapterList, chapterName: $chapterName, chapterUrl: $chapterUrl, updateTime: $updateTime}';
  }
}

/// Description :
/// @author zaze
/// @date 2022/8/5 - 7:30
class BookInfoRule {
  BookRule author = BookRule(ruleName: "作者");
  BookRule coverUrl = BookRule(ruleName: "封面");
  BookRule intro = BookRule(ruleName: "简介");
  BookRule tags = BookRule(ruleName: "类型");
  BookRule lastChapter = BookRule(ruleName: "最后章节名");
  BookRule name = BookRule(ruleName: "书名");
  BookRule tocUrl = BookRule(ruleName: "章节列表");
  BookRule wordCount = BookRule(ruleName: "字数");

  BookInfoRule();

  BookInfoRule.fromJson(dynamic json) {
    author.rule = json["author"];
    coverUrl.rule = json["coverUrl"];
    intro.rule = json["intro"];
    tags.rule = json["tags"];
    lastChapter.rule = json["lastChapter"];
    name.rule = json["name"];
    tocUrl.rule = json["tocUrl"];
  }

  Map<String, dynamic> toJson() {
    return {
      "author": author.rule,
      "coverUrl": coverUrl.rule,
      "intro": intro.rule,
      "tags": tags.rule,
      "lastChapter": lastChapter.rule,
      "name": name.rule,
      "tocUrl": tocUrl.rule,
      "wordCount": wordCount.rule,
    };
  }

  @override
  String toString() {
    return 'BookInfoRule{author: $author, coverUrl: $coverUrl, intro: $intro, kind: $tags, lastChapter: $lastChapter, name: $name, tocUrl: $tocUrl}';
  }
}

/// Description : 章节内容规则
/// @author zaze
/// @date 2022/8/5 - 7:47

@JsonSerializable()
class ContentRule {
  BookRule content = BookRule(ruleName: "内容");

  // BookRule replaceRegex = BookRule(ruleName: "替换规则");
  ContentRule();

  factory ContentRule.fromJson(Map<String, dynamic> json) =>
      _$ContentRuleFromJson(json);

  Map<String, dynamic> toJson() => _$ContentRuleToJson(this);

  @override
  String toString() {
    return 'ContentRule{content: $content}';
  }
}
