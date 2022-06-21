import 'package:flutter/material.dart';
import 'package:shosai/pages/bookshelf.dart';
import 'package:shosai/utils/log.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedTabIndex = 0;

  void _onItemTapped(int tabIndex) {
    setState(() {
      _selectedTabIndex = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabPages = [
      BookshelfPage(),
      BookshelfPage(),
      // Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text(
      //         'You have pushed the button this many times:',
      //       ),
      //       Text(
      //         '$_selectedTabIndex',
      //         style: Theme.of(context).textTheme.headline4,
      //       )
      //     ],
      //   ),
      // )
    ];
    var bottomNavigationBarItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: "书架",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.book),
        label: "书架",
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: tabPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomNavigationBarItems,
        currentIndex: _selectedTabIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _onItemTapped(0);
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    printD("_HomePageState", "didChangeAppLifecycleState: $state");
  }
}
