import 'package:flutter/material.dart';

class ScreenSize {
  static final ScreenSize _instance = ScreenSize._internal();

  factory ScreenSize() {
    return _instance;
  }

  ScreenSize._internal();

  late double width;
  late double height;

  void init(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }
}
