import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/pages/page_operator.dart';
import 'package:shosai/pages/read_model.dart';
import 'package:shosai/pages/single_page.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';

import '../data/book_state.dart';

/// 垂直滑动模式
class VerticalPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return LoadingBuild<void>.circle(
          future: context
              .read<PageModel>()
              .init(boxConstraints.maxWidth, boxConstraints.maxHeight),
          success: (context, _) {
            return _PageContent();
          },
        );
      },
    );
  }
}

class _PageContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PageContentState();
  }
}

class _PageContentState extends State<_PageContent> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PageModel>(
      builder: (context, pageModel, _) {
        MyLog.d(
            "_ReadViewState", "connectionState: ${pageModel.connectionState}");
        if (pageModel.connectionState == ConnectionState.done) {
          int initialPage = context.read<PageModel>().initialPage;
          List<PageState> pages = pageModel.showPages;
          MyLog.d("_ReadViewState", "success: $initialPage: $pages");
          // 下一帧再处理， 保证绘制结束
          // context.read<ReadCache>().init(initialPage, pages.length);
          PageController controller = PageController(initialPage: initialPage);
          return ListView.builder(
            // controller: controller,
            scrollDirection: Axis.vertical,
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  SinglePageView(pages[index]),
                  // OperatorView(controller)
                ],
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
