// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookSource _$BookSourceFromJson(Map<String, dynamic> json) => BookSource(
      url: json['url'] as String? ?? "",
      name: json['name'] as String? ?? "",
    )
      ..tags = json['tags'] as String?
      ..comment = json['comment'] as String?
      ..searchUrl = BookUrl.fromJson(json['searchUrl'] as Map<String, dynamic>)
      ..searchRule = SearchRule.fromJson(json['searchRule'])
      ..tocRule = TocRule.fromJson(json['tocRule'])
      ..bookInfoRule = BookInfoRule.fromJson(json['bookInfoRule'])
      ..contentRule =
          ContentRule.fromJson(json['contentRule'] as Map<String, dynamic>)
      ..lastUpdateTime = json['lastUpdateTime'] as int
      ..errorFlag = json['errorFlag'] as int;

Map<String, dynamic> _$BookSourceToJson(BookSource instance) =>
    <String, dynamic>{
      'url': instance.url,
      'name': instance.name,
      'tags': instance.tags,
      'comment': instance.comment,
      'searchUrl': instance.searchUrl,
      'searchRule': instance.searchRule,
      'tocRule': instance.tocRule,
      'bookInfoRule': instance.bookInfoRule,
      'contentRule': instance.contentRule,
      'lastUpdateTime': instance.lastUpdateTime,
      'errorFlag': instance.errorFlag,
    };

BookUrl _$BookUrlFromJson(Map<String, dynamic> json) => BookUrl(
      path: json['path'] as String?,
      method: json['method'] as String? ?? "GET",
    )
      ..params = (json['params'] as List<dynamic>)
          .map((e) => UrlParam.fromJson(e as Map<String, dynamic>))
          .toList()
      ..body = (json['body'] as List<dynamic>)
          .map((e) => UrlParam.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$BookUrlToJson(BookUrl instance) => <String, dynamic>{
      'path': instance.path,
      'method': instance.method,
      'params': instance.params,
      'body': instance.body,
    };

UrlParam _$UrlParamFromJson(Map<String, dynamic> json) => UrlParam(
      json['key'] as String,
      ParamValue.fromJson(json['value'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UrlParamToJson(UrlParam instance) => <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };

ParamValue _$ParamValueFromJson(Map<String, dynamic> json) => ParamValue(
      json['value'] as String,
    )..encrypt = json['encrypt'] as String?;

Map<String, dynamic> _$ParamValueToJson(ParamValue instance) =>
    <String, dynamic>{
      'value': instance.value,
      'encrypt': instance.encrypt,
    };

BookRule _$BookRuleFromJson(Map<String, dynamic> json) => BookRule(
      rule: json['rule'] as String?,
      ruleName: json['ruleName'] as String?,
    );

Map<String, dynamic> _$BookRuleToJson(BookRule instance) => <String, dynamic>{
      'rule': instance.rule,
      'ruleName': instance.ruleName,
    };

ContentRule _$ContentRuleFromJson(Map<String, dynamic> json) => ContentRule()
  ..content = BookRule.fromJson(json['content'] as Map<String, dynamic>);

Map<String, dynamic> _$ContentRuleToJson(ContentRule instance) =>
    <String, dynamic>{
      'content': instance.content,
    };
