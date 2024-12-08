import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pin_box_decoration.dart';
import 'pin_code_config.dart';

/// A customizable PIN code text field widget
class PinCodeTextField extends StatefulWidget {
  /// Configuration for the PIN code text field
  final PinCodeConfig config;

  /// Callback when the PIN code value changes
  final ValueChanged<String>? onChanged;

  /// Callback when the PIN code is completed
  final ValueChanged<String>? onCompleted;

  /// Custom controller for the text field
  final TextEditingController? controller;

  /// Custom focus node for the text field
  final FocusNode? focusNode;

  /// Custom text style for the PIN code digits
  final TextStyle? textStyle;

  /// Decoration for the PIN code boxes
  final BoxDecoration? pinBoxDecoration;

  /// Cursor color
  final Color? cursorColor;

  /// Cursor width
  final double? cursorWidth;

  /// Cursor height
  final double? cursorHeight;

  /// Context menu builder
  final Widget Function(BuildContext, EditableTextState)? contextMenuBuilder;

  const PinCodeTextField({
    super.key,
    PinCodeConfig? config,
    this.onChanged,
    this.onCompleted,
    this.controller,
    this.focusNode,
    this.textStyle,
    this.pinBoxDecoration,
    this.cursorColor,
    this.cursorWidth,
    this.cursorHeight,
    this.contextMenuBuilder,
  }) : config = config ?? const PinCodeConfig();

  @override
  State<PinCodeTextField> createState() => _PinCodeTextFieldState();
}

class _PinCodeTextFieldState extends State<PinCodeTextField> {
  /// Internal controller for the text field
  late TextEditingController _controller;

  /// Internal focus node for the text field
  late FocusNode _focusNode;

  /// List to track individual pin box values
  late List<String> _pinValues;

  /// Key for the editable text widget
  final GlobalKey _editableTextKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Initialize controller and focus node
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize pin values
    _pinValues = List.filled(widget.config.length, '');

    // Add listener to update pin values
    _controller.addListener(_updatePinState);
  }

  /// Updates the state of pin values when text changes
  void _updatePinState() {
    setState(() {
      // Update pin values based on current text
      final text = _controller.text;
      _pinValues = List.filled(widget.config.length, '');
      for (int i = 0; i < text.length && i < widget.config.length; i++) {
        _pinValues[i] = text[i];
      }
    });

    // Trigger callbacks
    if (_controller.text.length == widget.config.length) {
      widget.onCompleted?.call(_controller.text);
    }
    widget.onChanged?.call(_controller.text);
  }

  @override
  void dispose() {
    // Dispose controllers if not provided externally
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  /// Default context menu builder
  Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Stack(
        children: [
          // Row of PIN code boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.config.length,
              (index) => _buildPinBox(index),
            ),
          ),

          // Invisible EditableText for input
          Positioned.fill(
            child: EditableText(
              key: _editableTextKey,
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.transparent, fontSize: 0),
              cursorColor: Colors.transparent,
              backgroundCursorColor: Colors.transparent,
              keyboardType: widget.config.keyboardType,
              inputFormatters: widget.config.getInputFormatters(),
              autofocus: false,
              readOnly: !widget.config.enabled,
              contextMenuBuilder: widget.config.showContextMenu
                  ? (widget.contextMenuBuilder ?? _defaultContextMenuBuilder)
                  : null,
              onChanged: (value) {
                // Handled by controller listener
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual PIN code box
  Widget _buildPinBox(int index) {
    final isFocused = _focusNode.hasFocus && index == _controller.text.length;
    final hasValue = index < _controller.text.length;

    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: widget.pinBoxDecoration ??
          PinBoxDecoration.defaultDecoration(
            context,
            isFocused: isFocused,
          ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // PIN code digit
          Text(
            widget.config.obscureText && hasValue ? '•' : _pinValues[index],
            style:
                widget.textStyle ?? Theme.of(context).textTheme.headlineSmall,
          ),

          // Cursor indicator
          if (isFocused)
            Container(
              width: widget.cursorWidth ?? 2,
              height: widget.cursorHeight ?? 24,
              decoration: BoxDecoration(
                color: widget.cursorColor ?? Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
