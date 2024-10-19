// ignore_for_file: unnecessary_this
import 'package:flutter_advanced_drop_down/util/screen_size.dart';

double getSize(double size, {bool scale = false}) {
  if (!scale) {
    return size;
  }
  double baseWidth = isMobile()
      ? 414
      : isTablet()
      ? 768
      : 1920;
  return size * (ScreenSize().width / baseWidth);
}

bool isMobile() {
  return ScreenSize().width < 768;
}

bool isTablet() {
  return ScreenSize().width >= 768 && ScreenSize().width < 1024;
}

bool isWeb() {
  return ScreenSize().width >= 1024;
}



