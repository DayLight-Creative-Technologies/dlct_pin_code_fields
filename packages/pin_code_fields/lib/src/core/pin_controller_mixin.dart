import 'package:flutter/widgets.dart';

import 'pin_input_controller.dart';

/// Mixin that handles [PinInputController] lifecycle management.
///
/// This mixin provides common controller initialization and disposal logic
/// used by [PinInput], [MaterialPinField], and [PinInputFormField].
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with PinControllerMixin {
///   @override
///   void initState() {
///     super.initState();
///     initPinController(
///       externalController: widget.pinController,
///       initialValue: widget.initialValue,
///     );
///   }
///
///   @override
///   void dispose() {
///     disposePinController();
///     super.dispose();
///   }
/// }
/// ```
mixin PinControllerMixin<T extends StatefulWidget> on State<T> {
  PinInputController? _internalController;
  bool _ownsController = false;

  /// The effective controller (external or internal).
  ///
  /// Only valid after [initPinController] has been called.
  PinInputController get effectiveController => _effectiveController!;
  PinInputController? _effectiveController;

  /// Whether this mixin owns (and should dispose) the controller.
  bool get ownsController => _ownsController;

  /// Initializes the PIN controller.
  ///
  /// If [externalController] is provided, it will be used.
  /// Otherwise, an internal controller is created with [initialValue].
  ///
  /// Returns the effective controller for convenience.
  PinInputController initPinController({
    required PinInputController? externalController,
    String? initialValue,
  }) {
    if (externalController == null) {
      _internalController = PinInputController(text: initialValue);
      _ownsController = true;
      _effectiveController = _internalController;
    } else {
      _ownsController = false;
      _effectiveController = externalController;
      // Set initial value on external controller if provided and empty
      if (initialValue != null && externalController.text.isEmpty) {
        externalController.text = initialValue;
      }
    }
    return _effectiveController!;
  }

  /// Reinitializes the controller when the widget updates.
  ///
  /// Call this in [didUpdateWidget] when the external controller changes.
  /// [onBeforeDispose] is called before disposing the old controller,
  /// allowing you to remove listeners.
  ///
  /// Returns the new effective controller.
  PinInputController reinitPinController({
    required PinInputController? newExternalController,
    required PinInputController? oldExternalController,
    String? initialValue,
    VoidCallback? onBeforeDispose,
  }) {
    if (newExternalController != oldExternalController) {
      onBeforeDispose?.call();
      disposePinController();
      return initPinController(
        externalController: newExternalController,
        initialValue: initialValue,
      );
    }
    return _effectiveController!;
  }

  /// Disposes the controller if owned by this mixin.
  ///
  /// Call this in your [State.dispose] method.
  void disposePinController() {
    if (_ownsController) {
      _internalController?.dispose();
      _internalController = null;
    }
    _effectiveController = null;
    _ownsController = false;
  }
}
