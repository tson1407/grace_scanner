import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the app lifecycle state.
final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>(
  (ref) => AppLifecycleNotifier(),
);

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState>
    with WidgetsBindingObserver {
  AppLifecycleNotifier() : super(AppLifecycleState.resumed) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
