import 'package:flutter/material.dart';

class SizedProgressIndicator extends StatelessWidget {
  final double? diameter;
  final double? value;
  final double padding;
  final double strokeWidth;
  final Color? color;

  const SizedProgressIndicator({
    super.key,
    this.diameter,
    this.value,
    this.padding = 0,
    this.color,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: SizedBox(
        height: diameter,
        width: diameter,
        child: CircularProgressIndicator(
          value: value,
          strokeWidth: strokeWidth,
          color: color,
        ),
      ),
    );
  }
}
