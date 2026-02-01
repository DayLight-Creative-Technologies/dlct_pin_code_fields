import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'gestures/context_menu_builder.dart';
import 'gestures/selection_gesture_builder.dart';
import 'haptics.dart';
import 'input_capture/invisible_text_field.dart';
import 'pin_cell_data.dart';
import 'pin_controller_mixin.dart';
import 'pin_input_controller.dart';
import 'pin_input_scope.dart';

/// Builder function for custom PIN cell rendering.
typedef PinCellBuilder = Widget Function(
  BuildContext context,
  List<PinCellData> cells,
);

/// Headless PIN input widget.
///
/// This widget captures keyboard input and manages PIN state but delegates
/// ALL visual rendering to the provided [builder]. You decide exactly how
/// each cell should look - this widget just provides the data.
///
/// Example:
/// ```dart
/// PinInput(
///   length: 6,
///   builder: (context, cells) {
///     return Row(
///       children: cells.map((cell) => MyCustomCell(data: cell)).toList(),
///     );
///   },
///   onCompleted: (pin) => print('PIN: $pin'),
/// )
/// ```
class PinInput extends StatefulWidget {
  const PinInput({
    super.key,
    required this.length,
    required this.builder,
    // Controller
    this.pinController,
    this.initialValue,
    // Input behavior
    this.keyboardType = TextInputType.number,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    // Behavior
    this.enabled = true,
    this.autoFocus = false,
    this.readOnly = false,
    this.autoDismissKeyboard = true,
    this.clearErrorOnInput = true,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.blinkWhenObscuring = true,
    this.blinkDuration = const Duration(milliseconds: 500),
    // Haptics
    this.enableHapticFeedback = true,
    this.hapticFeedbackType = HapticFeedbackType.light,
    // Gestures
    this.enablePaste = true,
    this.selectionControls,
    this.contextMenuBuilder = defaultPinContextMenuBuilder,
    // Callbacks
    this.onChanged,
    this.onCompleted,
    this.onSubmitted,
    this.onEditingComplete,
    this.onTap,
    // Keyboard
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20),
    // Autofill
    this.enableAutofill = false,
    this.autofillContextAction = AutofillContextAction.commit,
  })  : assert(length > 0, 'Length must be greater than 0'),
        assert(
          obscuringCharacter.length > 0,
          'Obscuring character must not be empty',
        );

  /// Number of PIN cells.
  final int length;

  /// Builder that receives cell data and returns the visual representation.
  ///
  /// This is where YOU decide how to render each cell. The builder receives
  /// a list of [PinCellData] objects containing all the state information
  /// needed to render each cell.
  final PinCellBuilder builder;

  /// Controller for the PIN input.
  ///
  /// Provides programmatic access to text, error state, and focus.
  /// If not provided, an internal controller will be created and managed.
  final PinInputController? pinController;

  /// Initial value for the PIN input.
  ///
  /// If provided, the PIN field will start with this value pre-filled.
  /// This is a convenience parameter - you can also set initial value
  /// via the controller: `PinInputController(text: '1234')`.
  final String? initialValue;

  /// The type of keyboard to display.
  final TextInputType keyboardType;

  /// The action button to display on the keyboard.
  final TextInputAction textInputAction;

  /// Additional input formatters to apply.
  final List<TextInputFormatter>? inputFormatters;

  /// How to capitalize text input.
  final TextCapitalization textCapitalization;

  /// Autofill hints for the text field.
  final Iterable<String>? autofillHints;

  /// Whether the field is enabled.
  ///
  /// When `false`, the field is visually grayed out and does not accept input.
  /// This is different from [readOnly], which prevents editing but maintains
  /// the normal visual appearance.
  ///
  /// Flutter convention:
  /// - `enabled: false` - grayed out, no interaction
  /// - `readOnly: true` - looks normal, but can't edit
  final bool enabled;

  /// Whether to auto-focus on mount.
  final bool autoFocus;

  /// Whether the field is read-only.
  final bool readOnly;

  /// Whether to dismiss the keyboard when PIN is complete.
  final bool autoDismissKeyboard;

  /// Whether to automatically clear error state when user types.
  ///
  /// When `true` (default), any error state is cleared as soon as the user
  /// enters a new character. Set to `false` if you want the error to persist
  /// until explicitly cleared via `controller.clearError()`.
  final bool clearErrorOnInput;

  /// Whether to obscure the entered text.
  final bool obscureText;

  /// Character used to obscure text.
  final String obscuringCharacter;

  /// Whether to briefly show the character before obscuring.
  final bool blinkWhenObscuring;

  /// Duration to show the character before obscuring.
  final Duration blinkDuration;

  /// Whether to trigger haptic feedback on input.
  final bool enableHapticFeedback;

  /// Type of haptic feedback to trigger.
  final HapticFeedbackType hapticFeedbackType;

  /// Whether to enable paste functionality.
  final bool enablePaste;

  /// Custom text selection controls.
  final TextSelectionControls? selectionControls;

  /// Builder for the context menu (paste functionality).
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Called when the text changes.
  final ValueChanged<String>? onChanged;

  /// Called when the PIN is complete (all cells filled).
  final ValueChanged<String>? onCompleted;

  /// Called when the user submits (keyboard action button).
  final ValueChanged<String>? onSubmitted;

  /// Called when editing is complete.
  final VoidCallback? onEditingComplete;

  /// Called when the widget is tapped.
  final VoidCallback? onTap;

  /// The brightness of the keyboard.
  final Brightness? keyboardAppearance;

  /// Padding when scrolling the field into view.
  final EdgeInsets scrollPadding;

  /// Whether to enable autofill (e.g., SMS OTP autofill).
  ///
  /// When enabled, the system may automatically fill in OTP codes
  /// received via SMS or suggest saved PINs/passwords.
  final bool enableAutofill;

  /// Action to perform when the autofill context is disposed.
  ///
  /// - [AutofillContextAction.commit]: Tell the system to save the data
  ///   (useful for password managers to save PINs/passwords)
  /// - [AutofillContextAction.cancel]: Tell the system to discard the data
  ///   (appropriate for one-time codes like OTP)
  final AutofillContextAction autofillContextAction;

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput>
    with TickerProviderStateMixin, PinControllerMixin
    implements TextSelectionGestureDetectorBuilderDelegate {
  // Constants
  static const _fallbackFocusDelay = Duration(milliseconds: 50);

  // Gesture handling
  late TextSelectionGestureDetectorBuilder _gestureBuilder;

  // Delegate properties
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get selectionEnabled =>
      widget.enabled && widget.enablePaste && !widget.readOnly;

  @override
  bool get forcePressEnabled => false;

  // State
  bool _isError = false;
  int _previousLength = 0;
  final Set<int> _justEnteredIndices = {};
  final Set<int> _justRemovedIndices = {};

  // Blink effect
  Timer? _blinkTimer;
  bool _isBlinking = false;

  // Convenience getters for underlying text controller and focus node
  TextEditingController get _textController => effectiveController.textController;
  FocusNode get _focusNode => effectiveController.focusNode;

  @override
  void initState() {
    super.initState();
    _initPinController();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _gestureBuilder = TextSelectionGestureDetectorBuilder(delegate: this);
    _handleAutoFocus();
  }

  void _initPinController() {
    // 1. Create or assign controller (mixin handles ownership and initial value)
    initPinController(
      externalController: widget.pinController,
      initialValue: widget.initialValue,
    );

    // 2. Setup listeners for error sync and text changes
    _attachControllerListeners();

    // 3. Validate and correct initial text if needed
    _validateInitialText();

    // 4. Initialize length tracking
    _previousLength = _textController.text.length;
  }

  /// Attaches listeners to the controller for error state synchronization.
  void _attachControllerListeners() {
    effectiveController.attach(onErrorTriggered: _triggerErrorAnimation);
    effectiveController.addListener(_onPinControllerChanged);
  }

  /// Detaches listeners from the controller.
  void _detachControllerListeners() {
    effectiveController.removeListener(_onPinControllerChanged);
    effectiveController.detach();
  }

  /// Validates that initial text doesn't exceed the PIN length.
  void _validateInitialText() {
    final currentText = _textController.text;
    final limitedText = _getLimitedText(currentText);

    if (limitedText != currentText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _textController.text = limitedText;
        }
      });
    }
  }

  void _onPinControllerChanged() {
    if (mounted) {
      // Sync error state from controller
      final controllerHasError = effectiveController.hasError;
      if (_isError != controllerHasError) {
        setState(() => _isError = controllerHasError);
      }
    }
  }

  void _triggerErrorAnimation() {
    if (mounted) {
      setState(() => _isError = true);
    }
  }

  void _handleAutoFocus() {
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _requestFocusSafely();
        }
      });
    }

    // Set initial selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _textController.selection = TextSelection.collapsed(
          offset: _textController.text.length,
        );
      }
    });
  }

  @override
  void didUpdateWidget(covariant PinInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Pin controller change
    if (widget.pinController != oldWidget.pinController) {
      // Use mixin's reinit with cleanup callback
      reinitPinController(
        newExternalController: widget.pinController,
        oldExternalController: oldWidget.pinController,
        initialValue: widget.initialValue,
        onBeforeDispose: () {
          _textController.removeListener(_onTextChanged);
          _focusNode.removeListener(_onFocusChanged);
          _detachControllerListeners();
        },
      );

      // Setup new controller
      _attachControllerListeners();
      _textController.addListener(_onTextChanged);
      _focusNode.addListener(_onFocusChanged);
    }

    // Length change
    if (widget.length != oldWidget.length) {
      _onTextChanged();
    }
  }

  @override
  void dispose() {
    _detachControllerListeners();
    _blinkTimer?.cancel();
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    disposePinController();
    super.dispose();
  }

  void _requestFocusSafely() {
    if (mounted && _focusNode.context != null) {
      FocusScope.of(context).requestFocus(_focusNode);
    } else if (mounted) {
      Future.delayed(_fallbackFocusDelay, () {
        if (mounted && _focusNode.context != null) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      editableTextKey.currentState?.hideToolbar();
    }
    if (mounted) setState(() {});
  }

  void _onTextChanged() {
    if (!mounted) return;

    // Haptic feedback
    if (widget.enableHapticFeedback) {
      triggerHaptic(widget.hapticFeedbackType);
    }

    // Clear error on input (if enabled)
    if (_isError && widget.clearErrorOnInput) {
      _isError = false;
      effectiveController.setErrorState(false);
      setState(() {});
    }

    final currentText = _textController.text;
    final limitedText = _getLimitedText(currentText);

    // Correct text if needed
    if (currentText != limitedText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _textController.value = TextEditingValue(
            text: limitedText,
            selection: TextSelection.collapsed(offset: limitedText.length),
          );
        }
      });
      return;
    }

    final currentLength = limitedText.length;

    // Track transition signals
    _updateTransitionSignals(currentLength);

    // Callbacks
    widget.onChanged?.call(limitedText);

    // Completion check
    if (currentLength == widget.length && _previousLength < widget.length) {
      widget.onCompleted?.call(limitedText);
      if (widget.autoDismissKeyboard) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    }

    _previousLength = currentLength;

    // Blink effect
    _handleBlinkEffect();

    setState(() {});
  }

  void _updateTransitionSignals(int currentLength) {
    _justEnteredIndices.clear();
    _justRemovedIndices.clear();

    if (currentLength > _previousLength) {
      // Characters were entered
      for (int i = _previousLength; i < currentLength; i++) {
        _justEnteredIndices.add(i);
      }
    } else if (currentLength < _previousLength) {
      // Characters were removed
      for (int i = currentLength; i < _previousLength; i++) {
        _justRemovedIndices.add(i);
      }
    }

    // Clear transition signals after one frame
    if (_justEnteredIndices.isNotEmpty || _justRemovedIndices.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _justEnteredIndices.clear();
            _justRemovedIndices.clear();
          });
        }
      });
    }
  }

  void _handleBlinkEffect() {
    if (!widget.obscureText || !widget.blinkWhenObscuring) return;

    _blinkTimer?.cancel();
    _isBlinking = true;

    _blinkTimer = Timer(widget.blinkDuration, () {
      if (mounted) {
        setState(() => _isBlinking = false);
      }
    });
  }

  String _getLimitedText(String text) {
    String filteredText = text;
    if (widget.keyboardType == TextInputType.number) {
      filteredText = text.replaceAll(RegExp(r'[^0-9]'), '');
    }
    return filteredText.length > widget.length
        ? filteredText.substring(0, widget.length)
        : filteredText;
  }

  void _handleSelectionChanged(
    TextSelection selection,
    SelectionChangedCause? cause,
  ) {
    if (widget.readOnly) return;
    // Force selection to end
    if (_textController.selection.baseOffset != _textController.text.length ||
        _textController.selection.extentOffset != _textController.text.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _textController.selection = TextSelection.collapsed(
            offset: _textController.text.length,
          );
        }
      });
    }
  }

  List<PinCellData> _buildCells() {
    final text = _textController.text;
    final cells = <PinCellData>[];

    for (int i = 0; i < widget.length; i++) {
      final isFilled = i < text.length;
      final isFocused = _focusNode.hasFocus && i == text.length;
      final isLastEntered = i == text.length - 1 && text.isNotEmpty;

      cells.add(PinCellData(
        index: i,
        character: isFilled ? text[i] : null,
        isFilled: isFilled,
        isFocused: isFocused,
        isError: _isError,
        isDisabled: !widget.enabled,
        wasJustEntered: _justEnteredIndices.contains(i),
        wasJustRemoved: _justRemovedIndices.contains(i),
        isBlinking: widget.obscureText &&
            widget.blinkWhenObscuring &&
            isLastEntered &&
            _isBlinking,
      ));
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _buildCells();
    final selectionControls = widget.selectionControls ??
        (selectionEnabled ? getDefaultSelectionControls(context) : null);

    Widget content = GestureDetector(
      onTap: () {
        if (widget.enabled && !_focusNode.hasFocus && !widget.readOnly) {
          _requestFocusSafely();
        }
        widget.onTap?.call();
      },
      child: _gestureBuilder.buildGestureDetector(
        behavior: HitTestBehavior.translucent,
        child: PinInputScope(
          cells: cells,
          obscureText: widget.obscureText,
          obscuringCharacter: widget.obscuringCharacter,
          hasFocus: _focusNode.hasFocus,
          requestFocus: _requestFocusSafely,
          child: Stack(
            children: [
              // User's custom UI
              widget.builder(context, cells),

              // Invisible input layer
              Positioned.fill(
                child: InvisibleTextField(
                  editableTextKey: editableTextKey,
                  controller: _textController,
                  focusNode: _focusNode,
                  length: widget.length,
                  readOnly: widget.readOnly,
                  selectionEnabled: selectionEnabled,
                  selectionControls: selectionControls,
                  contextMenuBuilder:
                      selectionEnabled ? widget.contextMenuBuilder : null,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textCapitalization: widget.textCapitalization,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onEditingComplete: widget.onEditingComplete,
                  onSelectionChanged: _handleSelectionChanged,
                  keyboardAppearance: widget.keyboardAppearance,
                  scrollPadding: widget.scrollPadding,
                  autofillHints: widget.enableAutofill ? widget.autofillHints : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with AutofillGroup if autofill is enabled
    if (widget.enableAutofill) {
      content = AutofillGroup(
        onDisposeAction: widget.autofillContextAction,
        child: content,
      );
    }

    return content;
  }
}
