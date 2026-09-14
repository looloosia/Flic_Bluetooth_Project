import 'package:flic_bluetooth_project/flic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_provider/flutter_provider.dart';
import 'package:flic_button/flic_button.dart';

class FlickProvider with ChangeNotifier {
  List<Flic> flics = [];

  void addFlic(Flic2Button newFlic, String uuid, String? pushAction, String? doublePushAction, String? holdAction) {
    flics.add(Flic(
        flicbutton: newFlic,
        uuid: uuid,
        pushAction: pushAction,
        doublePushAction: doublePushAction,
      holdAction: holdAction,
    ));
    notifyListeners();
  }

  void editFlicAction(int flicIndex, ClickType clickType, String action) {
    switch (clickType) {
      case (ClickType.pushAction):
        flics[flicIndex].pushAction = action;
      case (ClickType.doublePushAction):
        flics[flicIndex].doublePushAction = action;
      case (ClickType.holdAction):
        flics[flicIndex].holdAction = action;
    }
    notifyListeners();
  }

  String? getFlickAction(String uuid, ClickType clickType) {
    for (var flic in flics) {
      if (flic.flicbutton.uuid == uuid) {
        switch (clickType) {
          case ClickType.pushAction:
            return flic.pushAction;
          case ClickType.doublePushAction:
            return flic.doublePushAction;
          case ClickType.holdAction:
            return flic.holdAction;
        }
      }
    }
  }

  void removeFlic(int index) {
    flics.removeAt(index);
    notifyListeners();
  }
}