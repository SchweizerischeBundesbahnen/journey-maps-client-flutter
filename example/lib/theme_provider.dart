import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeProvider({bool? isDark, bool? useSystemTheme}) {
    this.isDark = isDark ?? WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    this.useSystemTheme = useSystemTheme ?? true;
    WidgetsBinding.instance.addObserver(this);
  }

  late bool isDark;
  late bool useSystemTheme;

  @override
  void didChangePlatformBrightness() {
    if (useSystemTheme) {
      isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      notifyListeners();
    }
  }

  void updateTheme(bool? isDarkMode) {
    if (isDarkMode == null) {
      useSystemTheme = true;
      isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    } else {
      useSystemTheme = false;
      isDark = isDarkMode;
    }
    notifyListeners();
  }
}
