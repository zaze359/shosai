import 'dart:async';
import 'dart:convert' as cvt;

import 'package:charset/charset.dart' as charset_util;

/// 字符编解码器
class CharsetCodec extends cvt.Encoding {
  static const utf8 = "UTF-8";

  /// UTF-16LE： 前两个字节 0XFF 0XFE
  static const utf16le = "UTF-16LE";

  /// UTF-16BE： 前两个字节 0XFE 0XFF
  static const utf16be = "UTF-16BE";

  /// UTF-32LE： 前两个字节 0XFF 0XFE 0X00 0X00
  static const utf32le = "UTF-32LE";

  /// UTF-32BE： 前两个字节 0xFE 0xFF 0x00 0x00
  static const utf32be = "UTF-32BE";

  CharsetCodec(this.charset);

  String charset;

  @override
  late DefaultDecoder decoder = CharsetDecoder(charset).decoder;

  @override
  late DefaultEncoder encoder = CharsetEncoder(charset).encoder;

  @override
  String get name => charset;

  ///
  static String matchCharset(List<int>? charCodes) {
    if (charCodes == null) {
      return utf8;
    }
    if (charset_util.hasUtf16LeBom(charCodes)) {
      return utf16le;
    } else if (charset_util.hasUtf16BeBom(charCodes)) {
      return utf16be;
    } else if (charset_util.hasUtf32leBom(charCodes)) {
      return utf32le;
    } else if (charset_util.hasUtf32beBom(charCodes)) {
      return utf32be;
    } else {
      return utf8;
    }
  }
}

/// 编码器
class CharsetEncoder {
  CharsetEncoder([this.charset]);

  String? charset;
  DefaultEncoder? _encoder;

  DefaultEncoder get encoder {
    return _encoder ?? _getEncoder(charset);
  }

  DefaultEncoder _getEncoder(String? charset) {
    switch (charset) {
      case CharsetCodec.utf8:
        return _Utf8Encoder();
      case CharsetCodec.utf16le:
        return _Utf16LeEncoder();
      case CharsetCodec.utf16be:
        return _Utf16BeEncoder();
      case CharsetCodec.utf32le:
        return _Utf32LeEncoder();
      case CharsetCodec.utf32be:
        return _Utf32BeEncoder();
      default:
        return _Utf8Encoder();
    }
  }

  Stream<List<int>> bind(Stream<String> stream) {
    return stream.map(convert);
  }

  List<int> convert(String input) {
    return encoder.convert(input);
  }

  List<int> encode(String input) {
    return convert(input);
  }
}

/// 解码器
class CharsetDecoder {
  CharsetDecoder([this.charset]);

  String? charset;

  DefaultDecoder? _decoder;

  DefaultDecoder get decoder {
    return _decoder ?? _getDecoder(charset);
  }

  DefaultDecoder _getDecoder(String? charset) {
    switch (charset) {
      case CharsetCodec.utf8:
        return _Utf8Decoder();
      case CharsetCodec.utf16le:
        return _Utf16LeDecoder();
      case CharsetCodec.utf16be:
        return _Utf16BeDecoder();
      case CharsetCodec.utf32le:
        return _Utf32LeDecoder();
      case CharsetCodec.utf32be:
        return _Utf32BeDecoder();
      default:
        return _Utf8Decoder();
    }
  }

  Stream<String> bind(Stream<List<int>> stream) {
    return stream.map(convert);
  }

  String convert(List<int> input) {
    charset ??= CharsetCodec.matchCharset(input);
    _decoder ??= _getDecoder(charset);
    return _decoder!.convert(input);
  }

  String decode(List<int> input) {
    return convert(input);
  }
}

// --------------------------------------------------
// 解码代理
// --------------------------------------------------
/// 默认使用utf8编码格式解码
class DefaultDecoder extends cvt.Converter<List<int>, String> {
  DefaultDecoder(this.decoder);

  cvt.Converter<List<int>, String> decoder;

  @override
  Sink<List<int>> startChunkedConversion(Sink<String> sink) {
    // MyLog.d("_DefaultDecoder", "startChunkedConversion: $decoder");
    return decoder.startChunkedConversion(sink);
  }

  @override
  String convert(List<int> input) {
    // MyLog.d("_Default8Decoder", "convert: ${input.length}");
    return decoder.convert(input);
  }
}

class DefaultEncoder extends cvt.Converter<String, List<int>> {
  DefaultEncoder(this.encoder);

  cvt.Converter<String, List<int>> encoder;

  @override
  Sink<String> startChunkedConversion(Sink<List<int>> sink) {
    // MyLog.d("_DefaultDecoder", "startChunkedConversion: $decoder");
    return encoder.startChunkedConversion(sink);
  }

  @override
  List<int> convert(String input) {
    // MyLog.d("_Default8Decoder", "convert: ${input.length}");
    return encoder.convert(input);
  }
}

/// Utf8Decoder
class _Utf8Decoder extends DefaultDecoder {
  _Utf8Decoder() : super(const cvt.Utf8Decoder(allowMalformed: true));
}

/// Utf8 Encoder
class _Utf8Encoder extends DefaultEncoder {
  _Utf8Encoder() : super(const cvt.Utf8Encoder());
}

/// Utf16Le Decoder
class _Utf16LeDecoder extends DefaultDecoder {
  _Utf16LeDecoder() : super(const charset_util.Utf16Decoder());

  @override
  String convert(List<int> input) {
    return (decoder as charset_util.Utf16Decoder).decodeUtf16Le(input);
  }
}

/// Utf16Le Encoder
class _Utf16LeEncoder extends DefaultEncoder {
  _Utf16LeEncoder() : super(const charset_util.Utf16Encoder());

  @override
  List<int> convert(String input) {
    return (encoder as charset_util.Utf16Encoder).encodeUtf16Le(input);
  }
}

/// Utf16Le Decoder
class _Utf16BeDecoder extends DefaultDecoder {
  _Utf16BeDecoder() : super(const charset_util.Utf16Decoder());

  @override
  String convert(List<int> input) {
    return (decoder as charset_util.Utf16Decoder).decodeUtf16Be(input);
  }
}

/// Utf16Be Encoder
class _Utf16BeEncoder extends DefaultEncoder {
  _Utf16BeEncoder() : super(const charset_util.Utf16Encoder());

  @override
  List<int> convert(String input) {
    return (encoder as charset_util.Utf16Encoder).encodeUtf16Be(input);
  }
}

/// Utf32Le Decoder
class _Utf32LeDecoder extends DefaultDecoder {
  _Utf32LeDecoder() : super(const charset_util.Utf32Decoder());

  @override
  String convert(List<int> input) {
    return (decoder as charset_util.Utf32Decoder).decodeUtf32Le(input);
  }
}

/// Utf32Le Encoder
class _Utf32LeEncoder extends DefaultEncoder {
  _Utf32LeEncoder() : super(const charset_util.Utf32Encoder());

  @override
  List<int> convert(String input) {
    // TODO 先临时处理一下
    List<int?> list =
        (encoder as charset_util.Utf32Encoder).encodeUtf32Le(input);
    return list.map((e) {
      return e ?? 0;
    }).toList();
  }
}

/// Utf32Be Decoder
class _Utf32BeDecoder extends DefaultDecoder {
  _Utf32BeDecoder() : super(const charset_util.Utf32Decoder());

  @override
  String convert(List<int> input) {
    return (decoder as charset_util.Utf32Decoder).decodeUtf32Be(input);
  }
}

class _Utf32BeEncoder extends DefaultEncoder {
  _Utf32BeEncoder() : super(const charset_util.Utf32Encoder());

  @override
  List<int> convert(String input) {
    return (encoder as charset_util.Utf32Encoder).encodeUtf32Be(input);
  }
}
