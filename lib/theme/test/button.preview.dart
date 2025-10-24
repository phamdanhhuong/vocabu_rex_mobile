import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/primary_button.dart';

@Preview(name: 'My Sample Text')
Widget mySampleText() {
  return const Text('Hello, World!');
}

@Preview(name: 'Primary Button')
Widget primaryButtonPreview() {
  return PrimaryButton();
}