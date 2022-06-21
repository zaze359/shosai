import 'package:flutter/material.dart';
import 'package:shosai/utils/log.dart';

typedef SuccessWidgetBuilder<T> = Widget Function(
    BuildContext context, T? value);

class LoadingBuild<T> extends FutureBuilder<T> {
  LoadingBuild(
      {super.key,
      Future<T>? future,
      required SuccessWidgetBuilder<T> success,
      Widget? error,
      Widget? loading})
      : super(
            future: future,
            builder: (context, snapshot) {
              // MyLog.d("LoadingBuild[$T]",
              //     "builder: ${snapshot.connectionState}/${snapshot.data}");
              if (snapshot.hasError) {
                MyLog.d("LoadingBuild[$T]",
                    "${snapshot.error}, ${snapshot.stackTrace}");
                return error ??
                    Center(
                      child: Text(
                        "加载失败: ${snapshot.error}, ${snapshot.stackTrace}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loading ??
                    const Center(
                      child: Text("加载中"),
                    );
              }
              return success(context, snapshot.data);
            });

  LoadingBuild.circle(
      {Future<T>? future,
      required SuccessWidgetBuilder<T> success,
      Widget? error})
      : this(
            future: future,
            success: success,
            error: error,
            loading: const Center(child: CircularProgressIndicator()));
}
//
// class LoadingBuild2<T> extends StreamBuilder<T> {
//   LoadingBuild2(
//       {super.key,
//       Stream<T>? stream,
//       required SuccessWidgetBuilder<T> success,
//       Widget? error,
//       Widget? loading})
//       : super(
//             stream: stream,
//             builder: (context, snapshot) {
//               printD("LoadingBuild2",
//                   "builder: ${snapshot.connectionState}/${snapshot.data}");
//               if (snapshot.hasError) {
//                 return error ??
//                     Center(
//                       child: Text(
//                         "加载失败: ${snapshot.error}, ${snapshot.stackTrace}",
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     );
//               }
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return loading ??
//                     const Center(
//                       child: Text("加载中"),
//                     );
//               }
//               return success(context, snapshot.data);
//             });
//
//   LoadingBuild2.circle(
//       {Stream<T>? stream,
//       required SuccessWidgetBuilder<T> success,
//       Widget? error})
//       : this(
//             stream: stream,
//             success: success,
//             error: error,
//             loading: const Center(child: CircularProgressIndicator()));
// }
