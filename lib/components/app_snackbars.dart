import 'dart:async';

import 'package:flutter/material.dart';

class AppSnackbars {
  AppSnackbars._();

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, Colors.green.shade700);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, Colors.red.shade700);
  }

  static void _showToast(
    BuildContext context,
    String message,
    Color backgaroundColor,
  ) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (context) => _SlideToastWidget(
            message: message,
            backgroundColor: backgaroundColor,
            onDismissed: () {
              overlayEntry.remove();
            },
          ),
    );

    overlay.insert(overlayEntry);
  }
}

class _SlideToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final VoidCallback onDismissed;

  const _SlideToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.onDismissed,
  });

  @override
  State<_SlideToastWidget> createState() => _SlideToastWidgetState();
}

class _SlideToastWidgetState extends State<_SlideToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 2.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: 3000), () {
      _closeWithAnimation();
    });
  }

  Future<void> _closeWithAnimation() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.down,
              onResize: () => _timer?.cancel(),
              onDismissed: (_) {
                _timer?.cancel();
                widget.onDismissed();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
