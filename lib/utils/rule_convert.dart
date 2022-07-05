import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shosai/data/book_source.dart';
import 'package:shosai/data/repository/book_repository.dart';
import 'package:shosai/utils/log.dart';

/// 规则转换
class ConvertRule {
  Future<List<BookSource>> formLegadoJson(String legadoRule) async {
    legadoRule =
        await rootBundle.loadString("assets/book_sources.json", cache: false);
    List legadoJson = json.decode(legadoRule);
    List<BookSource> list = [];
    for (var element in legadoJson) {
      try {
        BookSource? source = _formLegadoJson(element);
        if (source != null) {
          var a = json.decode(json.encode(source));
          printD("ConvertRule formLegadoJson : ${a.runtimeType} ${a}");
          list.add(source);
        }
      } on Exception catch (e, s) {
        // printD("ConvertRule formLegadoJson error: $e  $s");
      }
    }
    await BookRepository().insertBookSources(list);
    return list;
  }

  BookSource? _formLegadoJson(Map<String, dynamic> json) {
    BookSource source =
        BookSource(url: json["bookSourceUrl"], name: json["bookSourceName"]);
    int bookSourceType = json["bookSourceType"];
    if (bookSourceType != 0) {
      printD("$source : 暂不支持 bookSourceType $bookSourceType");
      return null;
    }
    source.tags = json["bookSourceGroup"];
    source.comment = json["bookSourceComment"];
    //
    String? searchUrl = json["searchUrl"];
    if (searchUrl == null) {
      return null;
    }
    checkSupport(searchUrl);
    var searchUrlArray = searchUrl.split(',{');
    var urlAndParams = searchUrlArray[0].split('?');
    source.searchUrl.path = urlAndParams[0];
    if (urlAndParams.length > 1) {
      source.searchUrl.params = _convertLegadoParams(urlAndParams[1]);
    }
    if (searchUrlArray.length > 1) {
      // var searchArgs = jsonDecode(searchUrlArray[1]);
      var searchArgs =
          jsonDecode("{${searchUrlArray[1]}".replaceAll("'", "\""));
      // printD("searchArgs: $searchArgs");
      source.searchUrl.method = searchArgs["method"];
      source.searchUrl.body = _convertLegadoParams(searchArgs["body"]);
    }
    Map<String, dynamic> ruleSearch = json["ruleSearch"];
    source.searchRule.bookList.rule =
        _convertLegadoRule(ruleSearch["bookList"]);
    source.searchRule.name.rule = _convertLegadoRule(ruleSearch["name"]);
    source.searchRule.author.rule = _convertLegadoRule(ruleSearch["author"]);
    source.searchRule.intro.rule = _convertLegadoRule(ruleSearch["intro"]);
    source.searchRule.tags.rule = _convertLegadoRule(ruleSearch["kind"]);
    source.searchRule.latestChapter.rule =
        _convertLegadoRule(ruleSearch["latestChapter"]);
    source.searchRule.updateTime.rule =
        _convertLegadoRule(ruleSearch["updateTime"]);
    source.searchRule.bookUrl.rule = _convertLegadoRule(ruleSearch["bookUrl"]);
    source.searchRule.coverUrl.rule =
        _convertLegadoRule(ruleSearch["coverUrl"]);
    source.searchRule.wordCount.rule =
        _convertLegadoRule(ruleSearch["wordCount"]);
    return source;
  }

  checkSupport(String rule) {
    if (rule.contains("@js:") ||
        rule.contains("@json:") ||
        rule.contains("<js>") ||
        rule.startsWith("+<js>") ||
        rule.contains("\$.") ||
        rule.contains("java.")) {
      throw Exception("un_support rule: $rule");
    }
  }

  String formatRule(String rule) {
    rule = rule.replaceAll('class.', '.');
    rule = rule.replaceAll('tag.', '');
    rule = rule.replaceAll('id.', '#');
    return rule;
  }

  /// 转换legado 参数列表语句
  /// {\n  \"method\": \"POST\",\n  \"body\": \"keyword={{key}}&page={{page}}\"\n}"
  List<UrlParam> _convertLegadoParams(String? params) {
    if (params == null || params.isEmpty) {
      return [];
    }
    return UrlParam.fromParamStr(params).map((e) {
      e.value.value = _convertLegadoParam(e.value.value);
      return e;
    }).toList();
  }

  /// 转换legado具体某个参数
  /// page={{page}}
  String _convertLegadoParam(String param) {
    // if (param.startsWith("{{") && param.endsWith("}}")) {
    //   printD("_convertLegadoParam: $param >> ${"\$${param.substring(1, param.length - 1)}"}");
    //   return "\$${param.substring(1, param.length - 1)}";
    // }
    return param.replaceAll("\n", "");
  }

  List<_Rule> _splitRules(List<_Rule> rules,
      {List<String> splitChars = const ['&&', '||', '%%']}) {
    if (rules.isEmpty || splitChars.isEmpty) {
      return rules;
    }
    String split = splitChars[0];
    List<_Rule> resultList = [];
    for (var rule in rules) {
      if (rule.contains(split)) {
        resultList.addAll(rule.rule.split(split).map((e) {
          return _Rule(e, reg: split);
        }));
      } else {
        resultList.add(rule);
      }
    }
    if (splitChars.length == 1) {
      return resultList;
    }
    return _splitRules(resultList,
        splitChars: splitChars.sublist(1, splitChars.length));
  }

  //
  String? _convertLegadoRule(String? rule) {
    if (rule == null || rule.isEmpty) {
      return null;
    }
    rule = formatRule(rule);
    checkSupport(rule);
    List<_Rule> rules = _splitRules([_Rule(rule)]);
    // printD("------------ _convertLegadoRule: $rule");
    if (rules.isEmpty) {
      return null;
    }
    // 先仅处理第一个
    var convertLegadoRule = rules[0].convertLegadoRule();
    printD("convertLegadoRule: '${rules[0].rule}' >> '$convertLegadoRule'");
    return convertLegadoRule;
  }

  toLegado(String rule) {}
}

class _Rule {
  String rule;
  String? reg;

  bool contains(Pattern other, [int startIndex = 0]) {
    return rule.contains(other);
  }

  _Rule(this.rule, {this.reg});

  String convertLegadoRule() {
    List<String> rules = rule.split('@');
    List<String> resultRules = [];
    String lastRule;
    if (rules.length > 1) {
      rules.sublist(0, rules.length - 1).forEach((element) {
        resultRules.addAll(_convertLegadoIndexRule(element));
      });
      lastRule = rules[rules.length - 1];
    } else {
      lastRule = rules[0];
    }
    // 取出最后一个，查找是否存在替换规则
    var index = lastRule.indexOf('##');
    if (index >= 0) {
      lastRule =
          "${lastRule.substring(0, index)}@#${lastRule.substring(index, lastRule.length)}";
      if (!lastRule.endsWith('###')) {
        lastRule = "$lastRule###";
      }
      // 包含正则，表示这里的规则是获取内容
      resultRules.add("\$$lastRule");
    } else {
      var list = _convertLegadoIndexRule(lastRule);
      var first = list[0];
      if (!first.startsWith('.') && !first.startsWith('#')) {
        // 不是id class，默认当标签处理
        list[0] = "\$$first";
      }
      resultRules.addAll(list);
    }
    if (resultRules.isNotEmpty) {
      return resultRules.fold<String>("", (String previousValue, element) {
        if (previousValue.isEmpty) {
          return element;
        }
        return "$previousValue@$element";
      });
    } else {
      return rule;
    }
  }

  List<String> _convertLegadoIndexRule(String rule) {
    List<String> resultRules = [];
    List<String> firstRuleArray = [];
    if (rule.contains('!')) {
      firstRuleArray = rule.split('!');
      resultRules.add(firstRuleArray[0]);
      resultRules.add("[[!${firstRuleArray[1]}]]");
    } else {
      firstRuleArray = rule.split('.');
      var end = firstRuleArray[firstRuleArray.length - 1];
      if (end.compareTo('0') < 0 || end.compareTo('9') > 0) {
        resultRules.add(rule);
      } else {
        // 去除末尾的.num:num... 例如(.1:2)
        resultRules.add(rule.substring(0, rule.length - end.length - 1));
        // 位置相关规则的转换
        resultRules.add("[[$end]]");
      }
    }
    return resultRules;
  }
}
