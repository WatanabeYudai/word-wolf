import 'package:flutter/material.dart';
import 'package:word_wolf/custom_widget/full_width_button.dart';

class SimpleInputField extends StatefulWidget {
  const SimpleInputField({
    Key? key,
    this.margin,
    required this.hintText,
    required this.buttonText,
    required this.onSubmit,
    this.validator,
    this.controller,
  }) : super(key: key);

  final EdgeInsetsGeometry? margin;
  final String hintText;
  final String buttonText;
  final void Function(String) onSubmit;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  @override
  State<StatefulWidget> createState() => _SimpleInputFieldState();
}

class _SimpleInputFieldState extends State<SimpleInputField> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: widget.margin,
            child: TextFormField(
              controller: widget.controller,
              validator: widget.validator,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FullWidthButton(
            margin: widget.margin,
            text: widget.buttonText,
            onTap: () => _onTap(),
          ),
        ],
      ),
    );
  }

  void _onTap() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    String text = widget.controller?.text ?? '';
    widget.onSubmit(text);
  }
}
