import 'package:flutter/material.dart';
import 'package:shosai/core/model/book_source.dart';

double rowHeight = 36;

/// 请求参数配置
class RequestArgsWidget extends StatefulWidget {
  // List tabs = ["Params", "Body", "Header", "Cookie", "Auth"];
  List<UrlParam> params;

  Function(UrlParam) addParam;

  RequestArgsWidget(this.params, this.addParam, {Key? key}) : super(key: key);

  TextStyle tabStyle = const TextStyle(fontSize: 18, color: Colors.black);
  late Map<Widget, Widget> tabMap = {
    Text(
      "Params",
      style: tabStyle,
    ): _ParamsWidget(params, addParam),
  };

  @override
  State<StatefulWidget> createState() {
    return _RequestArgsWidgetState();
  }
}

class _RequestArgsWidgetState extends State<RequestArgsWidget> {
  @override
  Widget build(BuildContext context) {
    double height = rowHeight * (widget.params.length + 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Text(
            "请求参数配置",
            style: TextStyle(color: Colors.red),
          ),
        ),
        DefaultTabController(
          length: widget.tabMap.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: widget.tabMap.keys.toList(),
              ),
              SizedBox(
                height: height,
                child: TabBarView(
                  children: widget.tabMap.values.toList(),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _ParamsWidget extends StatefulWidget {
  _ParamsWidget(this.params, this.addParam);

  List<UrlParam> params;

  Function(UrlParam) addParam;

  @override
  State<StatefulWidget> createState() {
    return _ParamsWidgetState();
  }
}

class _ParamsWidgetState extends State<_ParamsWidget> {
  addParams(String key, String value) {
    setState(() {
      widget.addParam(UrlParam.fromKV(key, value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      // dividerThickness: 0.0,
      // headingTextStyle: TextStyle(
      //   fontSize: 14.0,
      //   fontWeight: FontWeight.w600,
      // ),
      // sortAscending: false,
      // showBottomBorder: true,
      border: TableBorder.all(color: Colors.black12),
      // showCheckboxColumn: false,
      headingRowHeight: rowHeight,
      dataRowHeight: rowHeight,
      columns: [DataColumn(label: Text("参数")), DataColumn(label: Text("值"))],
      // 列名
      rows: buildRows(widget.params), // 数据
    );
  }

  List<DataRow> buildRows(List<UrlParam> params) {
    List<DataRow> dataRows = [];
    for (int i = 0; i < params.length; i++) {
      UrlParam param = params[i];
      dataRows.add(
        DataRow(
          // selected: true,
          // onSelectChanged: (s) {},
          cells: [
            DataCell(
              TextFormField(
                decoration: const InputDecoration(border: InputBorder.none),
                initialValue: param.key,
                onChanged: (v) {
                  param.key = v;
                },
              ),
            ),
            DataCell(
              TextFormField(
                decoration: const InputDecoration(border: InputBorder.none),
                initialValue: param.value.value,
                onChanged: (v) {
                  param.value.value = v;
                },
              ),
            ),
          ],
        ),
      );
    }
    // 增加一个待输入行
    dataRows.add(DataRow(
      // selected: false,
      // onSelectChanged: (s) {},
      cells: [
        DataCell(
          TextFormField(
            decoration: const InputDecoration(border: InputBorder.none),
            initialValue: "",
            onChanged: (v) {
              addParams(v, "");
            },
          ),
        ),
        DataCell(
          TextFormField(
            decoration: const InputDecoration(border: InputBorder.none),
            initialValue: "",
            onChanged: (v) {
              addParams("", v);
            },
          ),
        ),
      ],
    ));
    return dataRows;
  }
}

class _AutoTable extends StatefulWidget {
  Map<String, String> _map;

  _AutoTable(this._map);

  @override
  State<StatefulWidget> createState() {
    return _AutoTableState();
  }
}

class _AutoTableState extends State<_AutoTable> {
  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(80),
        1: FixedColumnWidth(50),
        2: FixedColumnWidth(50),
        4: FixedColumnWidth(200),
      },
      border: TableBorder.all(
          color: Colors.green, width: 2.0, style: BorderStyle.solid),
      children: [
        TableRow(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            children: [
              Text(
                '参数名',
              ),
              Text(
                '值',
              ),
              Text(
                '年龄',
              ),
            ]),
        TableRow(children: [
          Text('男'),
          Text('20'),
        ]),
        TableRow(children: [
          Text('李四'),
          Text('女'),
          Text('28'),
        ]),
      ],
    );
  }
}
