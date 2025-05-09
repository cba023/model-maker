import 'package:flutter/material.dart';

class CheckboxWithText extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color? activeColor;
  final TextStyle? textStyle;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;

  const CheckboxWithText({
    Key? key,
    required this.text,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.green,
    this.textStyle,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Checkbox(value: value, onChanged: onChanged, activeColor: activeColor),
        SizedBox(width: spacing),
        Text(text, style: textStyle ?? Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
