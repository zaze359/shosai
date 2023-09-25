import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/core/model/book_state.dart';
import 'package:shosai/feature/read/operator_widget.dart';
import 'package:shosai/feature/read/book_read_vm.dart';
import 'package:shosai/feature/read/read_tip_bar.dart';
import 'package:shosai/feature/read/single_page_view.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';

/// 水平翻页模式
class HorizontalMode extends StatefulWidget {
  const HorizontalMode({super.key});

  @override
  State<StatefulWidget> createState() {
    return HorizontalModeState();
  }
}

class HorizontalModeState extends State<HorizontalMode> {
  @override
  Widget build(BuildContext context) {
    MyLog.d("HorizontalPage: build");
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return LoadingBuild<void>.circle(
                future: context.read<BookReadViewModel>().init(boxConstraints.maxWidth,
                    boxConstraints.maxHeight - ReadTipBar.readTipBarHeight),
                success: (context, _) {
                  return Consumer<BookReadViewModel>(
                    builder: (context, pageModel, _) {
                      MyLog.d("HorizontalPage",
                          "connectionState: ${pageModel.connectionState}");
                      if (pageModel.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Text(
                            "正在加载中...",
                            style: TextStyle(fontSize: 24),
                          ),
                        );
                      } else {
                        List<PageState> pages = pageModel.showPages;
                        MyLog.d("HorizontalPage",
                            "success: ${pageModel.initialPage + 1}: ${pages.length}");
                        return _PageContent(
                            pageModel.initialPage, pageModel.showPages);
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyLog.d("HorizontalPage didChangeDependencies");
  }
}

class _PageContent extends StatefulWidget {
  final int initialPage;
  final List<PageState> pages;

  // 不复用，保证initialPage能生效
  _PageContent(this.initialPage, this.pages) : super(key: UniqueKey()) {
    if (pages.isEmpty) {
      pages.add(PageState.empty());
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _PageContentState();
  }
}

class _PageContentState extends State<_PageContent> {
  PageController? controller;

  @override
  void initState() {
    controller = PageController(initialPage: widget.initialPage);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MyLog.d("_PageContentState build pages: ${widget.pages.length}");
    return PageView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: widget.pages.length,
      onPageChanged: (index) {
        context.read<BookReadViewModel>().updatePage(index);
      },
      itemBuilder: (context, index) {
        PageState page = widget.pages[index];
        return Stack(
          children: [
            Column(
              children: [
                Expanded(child: SinglePageView(page)),
                ReadTipBar(page),
              ],
            ),
            OperatorWidget(controller)
          ],
        );
      },
    );
  }
}
