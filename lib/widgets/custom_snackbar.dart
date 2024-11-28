import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/utils/colors.dart';

SnackBar customSnackBar(String message, WidgetRef ref) {
  return SnackBar(
    backgroundColor: Colors.black,
    content: Text(message, style: const TextStyle(color: Colors.white),),
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Got it',
      textColor: AppTheme.accentColor(ref),
      onPressed: () {},
    ),
  );
}
