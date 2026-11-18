import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_layout.dart';
import 'theme_provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final themeProvider = ThemeProvider();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (BuildContext context, ThemeProvider themeProvider, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SBBTheme.light(),
          darkTheme: SBBTheme.dark(),
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
          home: const AppLayout(),
        ),
      ),
    );
  }
}
