import 'package:flutter/cupertino.dart';

class PlaybackRoute extends CupertinoPageRoute {
  // ignore: use_super_parameters
  PlaybackRoute({builder}) : super(builder: builder);
  
  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}

class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  CustomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);  // Start position (off-screen below)
            const end = Offset.zero;  // End position (center of the screen)
            const curve = Curves.ease;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
        );
}
