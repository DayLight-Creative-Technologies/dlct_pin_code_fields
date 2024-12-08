import 'package:flutter/material.dart';

/// Provides default and customizable decorations for PIN code boxes
class PinBoxDecoration {
  /// Creates a default box decoration for PIN code fields
  static BoxDecoration defaultDecoration(
    BuildContext context, {
    bool isFocused = false,
    Color? borderColor,
    double borderWidth = 2,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor ?? 
               (isFocused 
                ? Theme.of(context).primaryColor 
                : Colors.grey),
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Creates a filled box decoration for PIN code fields
  static BoxDecoration filledDecoration({
    Color fillColor = Colors.grey,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Creates an outlined box decoration with custom properties
  static BoxDecoration outlinedDecoration({
    Color borderColor = Colors.blue,
    double borderWidth = 2,
    double borderRadius = 8,
  }) {
    return BoxDecoration(
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
