import 'package:flutter/material.dart';

class RetryDataFetch extends StatelessWidget {
  final String label;
  final void Function() onPressed;
  final Color? color;
  final String buttonText;
  final double labelFontSize;

  const RetryDataFetch({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.buttonText = 'Retry',
    this.labelFontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
          ),
        ),
        const SizedBox(height: 5),
        TextButton.icon(
          onPressed: onPressed,
          style: ButtonStyle(foregroundColor: MaterialStatePropertyAll(color)),
          icon: const Icon(Icons.refresh),
          label: Text(buttonText),
        )
      ],
    );
  }
}
