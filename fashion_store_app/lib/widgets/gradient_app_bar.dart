import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// App bar with brand gradient; works with [ThemeData.appBarTheme].
PreferredSizeWidget fashionAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
  bool centerTitle = true,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    centerTitle: centerTitle,
    flexibleSpace: Container(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
    ),
    title: Text(title),
    actions: actions,
    bottom: bottom,
  );
}
