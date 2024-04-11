import 'package:flutter/material.dart';

class SizedProgressIndicator extends StatelessWidget {
  final double? diameter;
  final double strokeWidth;
  final Color? color;

  const SizedProgressIndicator({
    super.key,
    this.diameter,
    this.strokeWidth = 4.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: diameter,
      width: diameter,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}
