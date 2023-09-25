import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/core/model/book_state.dart';
import 'package:shosai/feature/read/operator_widget.dart';
import 'package:shosai/feature/read/book_read_vm.dart';
import 'package:shosai/feature/read/single_page_view.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';


/// 垂直滑动模式
class VerticalMode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return LoadingBuild<void>.circle(
          future: context
              .read<BookReadViewModel>()
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
    return Consumer<BookReadViewModel>(
      builder: (context, pageModel, _) {
        MyLog.d(
            "_ReadViewState", "connectionState: ${pageModel.connectionState}");
        if (pageModel.connectionState == ConnectionState.done) {
          int initialPage = context.read<BookReadViewModel>().initialPage;
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
