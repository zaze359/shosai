import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/display_util.dart';
import 'package:shosai/utils/log.dart';

void main() {
  runApp(const MyApp());
  MyLog.d("main",
      "Display(${Display.physicalWidth}/${Display.physicalHeight})/${Display.devicePixelRatio}");
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  //
  // 设置系统状态栏导航栏模式
  // SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  // SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double densityAmt = 0.0;
    VisualDensity density =
        VisualDensity(horizontal: densityAmt, vertical: densityAmt);
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: "/",
      theme: ThemeData(
          primarySwatch: Colors.blue,
          iconTheme: const IconThemeData(color: Colors.teal),
          visualDensity: density),
      // routes: RouteConfiguration.routes,
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
    );
  }
}
