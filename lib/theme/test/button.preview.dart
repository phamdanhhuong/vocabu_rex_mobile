import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';

@Preview(name: 'All AppButton Variants')
Widget appButtonVariantsPreview() {
  return Material(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Variants', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              AppButton(label: 'Primary', onPressed: () {}, variant: ButtonVariant.primary, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Secondary', onPressed: () {}, variant: ButtonVariant.secondary, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Ghost', onPressed: () {}, variant: ButtonVariant.ghost, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Destructive', onPressed: () {}, variant: ButtonVariant.destructive, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Bee', onPressed: () {}, variant: ButtonVariant.bee, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Macaw', onPressed: () {}, variant: ButtonVariant.macaw, width: 120),
            ],
          ),
          SizedBox(height: 24),
          Text('Sizes', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              AppButton(label: 'Small', onPressed: () {}, size: ButtonSize.small, width: 100),
              SizedBox(width: 12),
              AppButton(label: 'Medium', onPressed: () {}, size: ButtonSize.medium, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Large', onPressed: () {}, size: ButtonSize.large, width: 140),
            ],
          ),
          SizedBox(height: 24),
          Text('Loading & Disabled', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              AppButton(label: 'Loading', onPressed: () {}, isLoading: true, width: 120),
              SizedBox(width: 12),
              AppButton(label: 'Disabled', onPressed: () {}, isDisabled: true, width: 120),
            ],
          ),
        ],
      ),
    ),
  );
}