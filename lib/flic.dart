import 'package:flic_button/flic_button.dart';

class Flic {
  final Flic2Button flicbutton;
  final String uuid;

  String? pushAction;
  String? doublePushAction;
  String? holdAction;

  Flic({
    required this.flicbutton,
    required this.uuid,
    this.pushAction, this.doublePushAction, this.holdAction,
  });
}

enum ClickType {
  pushAction,
  doublePushAction,
  holdAction,
}

enum ActionType {
  standby,
  reboot,
  playPause,
  next,
  prev,
  mute,
  volume10,
  volume20,
  volume30,
}