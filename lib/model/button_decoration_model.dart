import 'package:flutter/material.dart';

import 'icon_decoration_model.dart';

class ButtonDecorationModel{

  final String? buttonText;
  final TextStyle? buttonTextStyle;
  final double? buttonCornerRadius;
  final Color? buttonBackgroundColor;
  final Color? buttonBackgroundBlurColor;
  final Color? buttonShadowColor;
  final Color? buttonBorderColor;
  final double? buttonBorderWidth;
  final Color? buttonProgressIndicatorColor;
  final Color? borderColor;
  final bool? showIcon;
  final String? iconName;
  final Color? iconColor;
  final double? iconSize;
  final double? buttonHeight;
  final double? buttonWidth;
  final Color? selectedBackgroundColor;
  final Color? selectedBorderColor;
  final Color? selectedTextColor;
  final Color? selectedIconColor;
  final double? iconHeight;
  final double? iconWidth;
  final double? borderRadius;
  final Color? buttonActiveColor;
  final Color? buttonInActiveColor;
  final IconDecorationModel? rejectedButtonIcon;

  ButtonDecorationModel({
  this.iconSize,
  this.buttonText,
  this.buttonTextStyle,
  this.buttonCornerRadius,
  this.buttonBackgroundColor,
  this.buttonBackgroundBlurColor,
  this.buttonBorderColor,
  this.buttonShadowColor,
  this.buttonProgressIndicatorColor,
  this.borderColor,
  this.showIcon,
  this.iconName,
  this.buttonHeight,
  this.buttonWidth,
  this.iconHeight,
  this.iconWidth,
  this.iconColor,
  this.borderRadius,
  this.selectedTextColor,
  this.selectedBackgroundColor,
  this.buttonBorderWidth,
  this.selectedIconColor,
  this.selectedBorderColor,
  this.buttonActiveColor,
  this.buttonInActiveColor,
  this.rejectedButtonIcon
  });

}