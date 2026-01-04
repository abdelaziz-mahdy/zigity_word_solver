// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zigity_word_solver/controllers/word_controller.dart';
import 'package:zigity_word_solver/controllers/wordle_controller.dart';
import 'package:zigity_word_solver/pages/zigity_solver_page.dart';
import 'package:zigity_word_solver/pages/wordle_solver_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WordController()),
        ChangeNotifierProvider(create: (_) => WordleController()),
      ],
      child: const MaterialApp(
        title: 'Zigity Word Solver',
        themeMode: ThemeMode.system,
        home: MyHomePage(title: 'Zigity Word Solver'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.grid_on), text: 'Zigity Solver'),
            Tab(icon: Icon(Icons.games), text: 'Wordle Solver'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ZigitySolverPage(),
          WordleSolverPage(),
        ],
      ),
    );
  }
}
