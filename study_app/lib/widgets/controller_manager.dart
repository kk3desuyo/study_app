// lib/controller_manager.dart
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

final PersistentTabController _globalTabController =
    PersistentTabController(initialIndex: 2);

PersistentTabController getGlobalTabController() {
  return _globalTabController;
}

void jumpToTab(int index) {
  print('Jumping to tab: $index');
  print('Controller is null: ${_globalTabController == null}');
  _globalTabController.jumpToTab(index);
}
