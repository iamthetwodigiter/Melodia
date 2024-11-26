import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/homepage_model.dart';
import 'package:melodia/services/api_calls.dart';

class HomePageNotifier extends StateNotifier<AsyncValue<HomePageModel>> {
  HomePageNotifier() : super(const AsyncValue.loading()) {
    loadHomePageData();
  }

  Future<void> loadHomePageData() async {
    try {
      final data = await homePageData();
      state = AsyncValue.data(data);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final homePageProvider =
    StateNotifierProvider<HomePageNotifier, AsyncValue<HomePageModel>>(
  (ref) => HomePageNotifier(),
);
