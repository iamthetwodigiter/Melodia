import 'package:flutter/cupertino.dart';

class CustomPageRoute extends CupertinoPageRoute {
  // ignore: use_super_parameters
  CustomPageRoute({builder}) : super(builder: builder);

  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);
}