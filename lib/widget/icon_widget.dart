import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconWidget extends StatefulWidget {
  IconWidget({
    Key? key,
    this.withPadding = true,
    required this.data,
    this.width = 12,
    this.height = 12,
    this.color,
    this.onClick,
  });

  final bool withPadding;
  final String data;
  final double width;
  final double height;
  final Color? color;
  final Function? onClick;

  @override
  State<IconWidget> createState() => _IconWidgetState();
}
class _IconWidgetState extends State<IconWidget> {

  @override
  Widget build(BuildContext context) {
    return widget.onClick != null
        ? InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        widget.onClick!();
      },
      child: iconWidget(),
    )
        : iconWidget();
  }

  iconWidget() {
    return Container(
      width: widget.withPadding ? 27 : null,
      height: widget.withPadding ? 27 : null,
      alignment: Alignment.center,
      constraints: widget.withPadding
          ? null
          : BoxConstraints(
          maxHeight: widget.height,
          maxWidth: widget.width,
      ),
      child: SvgPicture.asset(
        widget.data,
        width: widget.width,
        height: widget.height,
        /// color: widget.color ?? Theme.of(context)primaryColor,
      ),
    );
  }

}

