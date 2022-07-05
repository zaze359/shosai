import 'package:flutter/material.dart';
import 'package:shosai/pages/book_source_page.dart';
import 'package:shosai/pages/bookshelf.dart';
import 'package:shosai/utils/log.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedTabIndex = 0;

  Map<BottomNavigationBarItem, Widget> tabPages = {
    const BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: "书架",
    ): BookshelfPage(),
    const BottomNavigationBarItem(
      icon: Icon(Icons.import_contacts),
      label: "书源",
    ): BookSourcePage()
  };

  void _onItemTapped(int tabIndex) {
    setState(() {
      _selectedTabIndex = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: tabPages.values.toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: tabPages.keys.toList(),
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
