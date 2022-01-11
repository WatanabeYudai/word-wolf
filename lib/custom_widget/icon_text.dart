import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  const IconText({
    Key? key,
    required this.text,
    required this.icon,
    this.alignment,
    this.style,
  }) : super(key: key);

  final String text;
  final Icon icon;
  final MainAxisAlignment? alignment;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment ?? MainAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          text,
          style: style ?? Theme.of(context).textTheme.headline6,
        ),
      ],
    );
  }
}
