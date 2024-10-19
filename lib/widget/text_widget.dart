import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  TextWidget({
    required this.data,
    this.fontWeight = FontWeight.normal,
    this.fontSize = 12,
    this.textAlign = TextAlign.start,
    this.height,
    this.textScaleFactor,
    this.color,
    this.textoverflow = TextOverflow.clip,
    this.isMandatory= false,
    this.trimLongText,
    this.isUnderline = false,
    this.maxLines,
    this.textStyle,
  });

  final String data;
  final FontWeight fontWeight;
  final double fontSize;
  final TextAlign textAlign;
  final Color? color;
  final bool isMandatory;
  final double? height;
  final TextOverflow textoverflow;
  final double? textScaleFactor;
  final int? maxLines;
  final bool isUnderline;
  final bool? trimLongText;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: trimLongText ==true ? data : "",
      child: Text.rich(
        TextSpan(
          children: <TextSpan>[
            TextSpan(
                text: trimLongText == true ? data : data,
                /// text: trimLongText == true ? data.truncateTo(50) : data,
                style: TextStyle(
                  fontFamily: "Inter",
                  color: color,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  height: height != null ? height! : height,
                  fontVariations: const [FontVariation('wght', 400)],
                  decoration: isUnderline
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ).merge(textStyle?.merge(TextStyle(
                    fontSize: textStyle?.fontSize ?? fontSize
                ),
                ),
                ),
            ),
            isMandatory
                ? TextSpan(
                text: " *",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: fontWeight,
                  fontSize: fontSize,
                  height: height != null ? height! : height,
                ).merge(textStyle?.merge(TextStyle(
                        fontSize: textStyle?.fontSize ?? 14),
                )))
                : const TextSpan(),
          ],
        ),
      ),
    );
  }
}