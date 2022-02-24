import 'package:flutter/material.dart';

class SimpleAlertDialog extends StatelessWidget {
  const SimpleAlertDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Icon(
        Icons.error,
        color: Colors.black54,
        size: 40,
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => {Navigator.pop(context)},
          child: const Text('OK'),
        )
      ],
    );
  }
}
