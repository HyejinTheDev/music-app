import 'package:flutter/material.dart';

/// Custom page transition builder — slide từ phải sang + fade in
/// Áp dụng tự động cho TẤT CẢ MaterialPageRoute trong app
class SlideUpFadeTransitionBuilder extends PageTransitionsBuilder {
  const SlideUpFadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Trang mới: slide từ phải sang trái (100% chiều rộng)
    final slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    // Fade in cho trang mới
    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Trang cũ: slide sang trái 30% khi bị đẩy ra
    final slideOut =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0.0)).animate(
          CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInOut),
        );

    return SlideTransition(
      position: slideOut,
      child: SlideTransition(
        position: slideIn,
        child: FadeTransition(opacity: fadeIn, child: child),
      ),
    );
  }
}
