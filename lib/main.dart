import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shosai/routes.dart';
import 'package:shosai/utils/debug.dart';
import 'package:shosai/utils/display_util.dart' as display;
import 'package:shosai/utils/log.dart';

void main() {
  debug();
  runApp(const MyApp());
  MyLog.d("main", '''
  Display：
  physicalWidth：${display.physicalWidth}
  physicalHeight: ${display.physicalHeight})
  devicePixelRatio: ${display.devicePixelRatio}
  textScaleFactor: ${display.textScaleFactor}
  ''');
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  // WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
  //   MyLog.d("main", "addPersistentFrameCallback: $timeStamp");
  // });
  // WidgetsBinding.instance.addTimingsCallback((timeStamp)  {
  //   MyLog.d("main", "addTimingsCallback: $timeStamp");
  // });
  // 设置系统状态栏导航栏模式
  // SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  // SystemChrome.setEnabledSystemUIMode(
  //     SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

final navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double densityAmt = 0.0;
    VisualDensity density =
        VisualDensity(horizontal: densityAmt, vertical: densityAmt);
    return MaterialApp(
      navigatorKey: navKey,
      title: 'Flutter Demo',
      initialRoute: "/",
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        // primarySwatch: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.teal),
        visualDensity: density,
      ),
      // routes: RouteConfiguration.routes,
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
    );
  }
}
