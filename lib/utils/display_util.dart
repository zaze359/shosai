import 'dart:ui';

/// 设备物理宽度，
get physicalWidth => window.physicalSize.width;

/// 设备物理高度，
get physicalHeight => window.physicalSize.height;

/// 设备像素比，类似 android 的 density
get devicePixelRatio => window.devicePixelRatio;

/// 字体缩放比例
get textScaleFactor => window.textScaleFactor;
