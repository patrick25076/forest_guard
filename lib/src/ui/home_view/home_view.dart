// Importing required packages

import 'package:flutter/material.dart';
import 'package:forest_guard/src/constants/screen_params.dart';
import 'package:forest_guard/src/ui/home_view/widgets/camera_and_overlay_widget.dart';

// HomeView is a StatefulWidget. This allows it to maintain state over the lifetime of the widget.
class HomeView extends StatefulWidget {
  // Constructor for HomeView
  const HomeView({super.key});

  // Creating the mutable state for this widget
  @override
  State<HomeView> createState() => _HomeViewState();
}

// The state for the HomeView StatefulWidget.
class _HomeViewState extends State<HomeView> {
  final GlobalKey _key = GlobalKey();

  @override
  initState() {
    super.initState();
    // Calls the after_layout method after the layout is completed.
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterLayout());
  }

  // This method is called after the layout is completed. It is used to obtain the size of the preview.
  void _afterLayout() {
    // Correctly obtaining the RenderBox and then the size
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    ScreenParams.previewSize = size;
  }

  // The build method is called every time the widget needs to be redrawn.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ScreenParams.screenSize = MediaQuery.of(context).size;

    // Return a Scaffold widget as the root of this widget's widget tree.
    return Scaffold(
      body: Column(
        children: [
          CameraAndOverlayWidget(colorScheme: colorScheme, key: _key),
          //Deprecated
          //LowerButtonsWidget(colorScheme: colorScheme)
        ],
      ),
    );
  }
}
