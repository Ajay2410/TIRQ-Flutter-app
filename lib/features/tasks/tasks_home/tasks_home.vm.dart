import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/locator.dart';

class TasksHomeViewModel extends ReactiveViewModel {
  final _navigationService = locator<NavigationService>();

  late TabController tabController;

  void init(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);
    notifyListeners();
  }

  int? _expandedCompletedTileIndex;
  int? get expandedCompletedTileIndex => _expandedCompletedTileIndex;

  int? _expandedPendingTileIndex;
  int? get expandedPendingTileIndex => _expandedPendingTileIndex;

  void navigateToRoute(String route) async {
    await _navigationService.navigateTo(route);
  }

  expandCompletedTile(int index) {
    if (_expandedCompletedTileIndex == index) {
      _expandedCompletedTileIndex = null;
    } else {
      _expandedCompletedTileIndex = index;
    }
    notifyListeners();
  }

  expandPendingTile(int index) {
    if (_expandedPendingTileIndex == index) {
      _expandedPendingTileIndex = null;
    } else {
      _expandedPendingTileIndex = index;
    }
    notifyListeners();
  }
}
