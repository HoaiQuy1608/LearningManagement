import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeProvider extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void onTabChange(int index) {
    state = index;
  }
}

final homeProvider = NotifierProvider<HomeProvider, int>(() {
  return HomeProvider();
});
