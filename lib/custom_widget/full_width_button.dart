import 'package:flutter/material.dart';

class FullWidthButton extends StatelessWidget {

  const FullWidthButton({
    Key? key,
    this.margin,
    required this.text,
    this.onTap,
  }) : super(key: key);

  final EdgeInsetsGeometry? margin;
  final String text;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      margin: margin,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}