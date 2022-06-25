import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shosai/pages/page_operator.dart';
import 'package:shosai/pages/read_model.dart';
import 'package:shosai/pages/read_tip_bar.dart';
import 'package:shosai/pages/single_page.dart';
import 'package:shosai/utils/log.dart';
import 'package:shosai/widgets/loading_widget.dart';

import '../data/book_state.dart';

/// 水平翻页模式
class HorizontalPage extends StatefulWidget {
  const HorizontalPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HorizontalPageState();
  }
}

class HorizontalPageState extends State<HorizontalPage> {
  @override
  Widget build(BuildContext context) {
    MyLog.d("HorizontalPage: build");
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, boxConstraints) {
              return LoadingBuild<void>.circle(
                future: context.read<PageModel>().init(boxConstraints.maxWidth,
                    boxConstraints.maxHeight - ReadTipBar.readTipBarHeight),
                success: (context, _) {
                  return Consumer<PageModel>(
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
  int initialPage;
  List<PageState> pages;

  // 不复用，保证initialPage能生效
  _PageContent(this.initialPage, this.pages) : super(key: UniqueKey());

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
    MyLog.d("_PageContentState build");
    return PageView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: widget.pages.length,
      onPageChanged: (index) {
        context.read<PageModel>().updatePage(index);
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
            OperatorView(controller)
          ],
        );
      },
    );
  }
}
