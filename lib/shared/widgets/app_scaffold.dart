import 'package:flutter/material.dart';
import 'watermark_overlay.dart';

/// Wraps every authenticated screen with institute watermark.
class AppScaffold extends StatelessWidget {
  final String? title;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showAppBar;

  const AppScaffold({
    super.key,
    this.title,
    this.appBar,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? resolvedAppBar = appBar;
    if (resolvedAppBar == null && showAppBar && title != null) {
      resolvedAppBar = AppBar(title: Text(title!), actions: actions);
    }

    return Scaffold(
      appBar: resolvedAppBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: WatermarkOverlay(child: body),
    );
  }
}
