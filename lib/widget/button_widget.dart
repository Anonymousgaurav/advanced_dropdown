import 'package:flutter/material.dart';
import 'package:flutter_advanced_drop_down/widget/text_widget.dart';

class ButtonWidget extends StatelessWidget {
  ButtonWidget(
      {required this.data,
      this.width = 110,
      this.height = 40,
      this.progressIndicatorSize = 20,
      this.progressIndicatorStrokeWidth = 2,
      required this.onClick,
      this.isInProgress = false,
      this.isBorder = false,
      this.showShadow = true,
      this.borderTopLeftRadius,
      this.borderTopRightRadius,
      this.borderBottomRightRadius,
      this.borderBottomLeftRadius,
      this.borderRadius = 6,
      this.borderWidth = 1,
      this.fontWeight = FontWeight.normal,
      this.fontSize = 12,
       this.buttonBackgroundColor,
      this.textStyle,
      this.buttonShadowColor,
      this.buttonProgressIndicatorColor,
      this.enabled = true,
      this.borderColor = Colors.transparent,
      this.textColor});

  final double? borderTopLeftRadius;
  final double? borderTopRightRadius;
  final double? borderBottomRightRadius;
  final double? borderBottomLeftRadius;
  final double width;
  final double height;
  final String data;
  final Function onClick;
  final bool isBorder;
  final bool isInProgress;
  final bool showShadow;
  final FontWeight fontWeight;
  final double fontSize;
  final double borderRadius;
  final double borderWidth;
  final double progressIndicatorSize;
  final double progressIndicatorStrokeWidth;
  final TextStyle? textStyle;
  final Color? textColor;
  final Color? borderColor;
  final Color? buttonBackgroundColor;
  final Color? buttonShadowColor;
  final Color? buttonProgressIndicatorColor;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderTopLeftRadius ?? borderRadius),
          topRight: Radius.circular(borderTopRightRadius ?? borderRadius),
          bottomLeft: Radius.circular(borderBottomLeftRadius ?? borderRadius),
          bottomRight: Radius.circular(borderBottomRightRadius ?? borderRadius),
        ),
        onTap: () {
          if (enabled) {
            if (!isInProgress) {
              onClick();
            }
          }
        },
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isBorder
                ? Border.all(
                    width: borderWidth,
                    color: borderColor ?? Theme.of(context).primaryColor)
                : null,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(borderTopLeftRadius ?? borderRadius),
              topRight: Radius.circular(borderTopRightRadius ?? borderRadius),
              bottomLeft:
                  Radius.circular(borderBottomLeftRadius ?? borderRadius),
              bottomRight:
                  Radius.circular(borderBottomRightRadius ?? borderRadius),
            ),
            color: buttonBackgroundColor ?? Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: buttonShadowColor ?? Colors.transparent,
                blurRadius: 20,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: isInProgress
              ? CircularProgressIndicator(
                  ///size: progressIndicatorSize,
                  strokeWidth: progressIndicatorStrokeWidth,
                  color: buttonProgressIndicatorColor ??
                      textColor ??
                      Theme.of(context).primaryColorLight,
                )
              : SelectionContainer.disabled(
                  child: TextWidget(
                    data: data,
                    textAlign: TextAlign.center,
                    color: textColor ?? Colors.white,
                    fontSize: fontSize,
                    textStyle: textStyle,
                  ),
                ),
        ),
      ),
    );
  }
}
