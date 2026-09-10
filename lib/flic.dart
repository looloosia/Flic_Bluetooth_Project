import 'package:flic_button/flic_button.dart';

class Flic {
  final Flic2Button flicbutton;

  String? pushAction;
  String? doublePushAction;
  String? holdAction;

  Flic({
    required this.flicbutton,
    this.pushAction, this.doublePushAction, this.holdAction,
  });
}

enum ClickType {
  pushAction,
  doublePushAction,
  holdAction,
}