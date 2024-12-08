import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration class for PIN code text fields
class PinCodeConfig {
  /// The number of PIN code digits
  final int length;

  /// Whether to obscure the text (like a password)
  final bool obscureText;

  /// Keyboard type for input
  final TextInputType keyboardType;

  /// Input formatters to validate or restrict input
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether to show context menu
  final bool showContextMenu;

  const PinCodeConfig({
    this.length = 4,
    this.obscureText = false,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.enabled = true,
    this.showContextMenu = true,
  });

  /// Creates input formatters with additional validation
  List<TextInputFormatter> getInputFormatters() {
    return [
      LengthLimitingTextInputFormatter(length),
      // Add any additional input formatters
      ...?inputFormatters,
      FilteringTextInputFormatter.digitsOnly, // Ensure only digits by default
    ];
  }

  /// Validates the PIN code
  bool validate(String value) {
    return value.length == length;
  }
}
