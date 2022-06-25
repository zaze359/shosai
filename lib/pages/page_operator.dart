import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/pages/read_model.dart';
import 'package:shosai/utils/log.dart';

/// TODO 后续考虑增加操作功能的自定义
/// 控制翻页、菜单等点击操作。
class OperatorView extends StatefulWidget {
  OperatorView(this._controller);

  PageController? _controller;

  @override
  State<StatefulWidget> createState() {
    return OperatorViewState();
  }
}

class OperatorViewState extends State<OperatorView> {
  late MapEntry<String, Function> prevPage = MapEntry("上一页", _prevPage);
  late MapEntry<String, Function> nextPage = MapEntry("下一页", _nextPage);
  late MapEntry<String, Function> toggleMenu =
      MapEntry("菜单", context.read<UIModel>().showMenu);

  Color color = Colors.grey;

  void _prevPage() {
    MyLog.d("_OperatorView", "_prevPage");
    double pre = (widget._controller?.page ?? 0) - 1;
    if (pre >= 0) {
      _animateToPage(pre);
    }
  }

  void _nextPage() {
    int max = context.read<PageModel>().showPages.length;
    double next = (widget._controller?.page ?? 0) + 1;
    // MyLog.d("_OperatorView", "_nextPage: $next; max $max");
    if (next < max) {
      _animateToPage(next);
    }
  }

  void _animateToPage(double offset) {
    widget._controller?.animateToPage(offset.toInt(),
        duration: const Duration(milliseconds: 200), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    MyLog.d("OperatorViewState", "build");
    return SafeArea(
      child: Visibility(
        visible: false,
        maintainState: true,
        maintainSize: true,
        maintainAnimation: true,
        maintainInteractivity: true,
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            double aspectRatio =
                boxConstraints.maxWidth / boxConstraints.maxHeight;
            return GridView(
              // controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: aspectRatio,
                // crossAxisSpacing: 4,
                // mainAxisSpacing: 4,
              ),
              children: [
                _TouchBlockView(prevPage, color: color),
                _TouchBlockView(prevPage, color: color),
                _TouchBlockView(nextPage, color: color),
                //
                _TouchBlockView(prevPage, color: color),
                _TouchBlockView(toggleMenu, color: color),
                _TouchBlockView(nextPage, color: color),
                //
                _TouchBlockView(prevPage, color: color),
                _TouchBlockView(nextPage, color: color),
                _TouchBlockView(nextPage, color: color),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TouchBlockView extends StatelessWidget {
  _TouchBlockView(this._map, {this.color = Colors.transparent});

  Color color;
  final MapEntry<String, Function> _map;

  void _onPressed() {
    _map.value();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onPressed,
      child: Container(
        color: Colors.grey, // 需要设置透明，否则默认透明部分不响应事件
        child: Center(
          child: Text(_map.key),
        ),
      ),
    );
  }
}
