import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filesProvider = StateProvider<List<File>?>((ref) {
  return [];
});
