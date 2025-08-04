import 'package:flutter/material.dart';

class ScreenEnterAnimation {
  late final AnimationController fadeController;
  late final AnimationController slideController;
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;

  ScreenEnterAnimation({required TickerProvider vsync}) {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeInOut,
    ));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void start() {
    fadeController.forward();
    slideController.forward();
  }

  void dispose() {
    fadeController.dispose();
    slideController.dispose();
  }
}
