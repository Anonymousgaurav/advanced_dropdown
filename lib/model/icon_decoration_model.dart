import 'package:flutter/material.dart';

class IconDecorationModel {

  final Color? iconColor;
  final double? iconHeight;
  final double? iconWidth;
  final Color? iconHolderColor;

  IconDecorationModel(
      { this.iconColor, this.iconHeight, this.iconWidth, this.iconHolderColor});

  IconDecorationModel replace(
      { Color? iconColor, double? iconHeight, double? iconWidth}) {
    return IconDecorationModel(iconColor: iconColor ?? this.iconColor,
      iconHeight: iconHeight ?? this.iconHeight,
      iconWidth: iconWidth ?? this.iconWidth,);
  }

  static IconDecorationModel withProxy(IconDecorationModel? iconDecorationModel,
      { required Color iconColor, required double iconHeight, required double iconWidth,}) {
    return IconDecorationModel(
      iconColor: iconDecorationModel?.iconColor ?? iconColor,
      iconHeight: iconDecorationModel?.iconHeight ?? iconHeight,
      iconWidth: iconDecorationModel?.iconWidth ?? iconWidth,

    );
  }
}