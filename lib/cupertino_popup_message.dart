import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoCenterPopup extends StatefulWidget {
  final String message;
  final Duration duration;
  final IconData icon;
  const CupertinoCenterPopup({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    required this.icon,
  });

  @override
  State<CupertinoCenterPopup> createState() => _CupertinoCenterPopupState();
}

class _CupertinoCenterPopupState extends State<CupertinoCenterPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: CupertinoColors.separator,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(widget.icon, size: 50.0, color: CupertinoColors.white),
              const SizedBox(height: 10.0),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: CupertinoColors.white, fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void showCupertinoCenterPopup(BuildContext context, String message, IconData icon) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => CupertinoCenterPopup(message: message, icon: icon,),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
