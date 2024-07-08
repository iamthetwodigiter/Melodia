import 'package:flutter_riverpod/flutter_riverpod.dart';

final downloadProgressProvider = StateProvider<double>((ref) {
  return 0;
});

final downloadDoneProvider = StateProvider<bool> ((ref) => false);