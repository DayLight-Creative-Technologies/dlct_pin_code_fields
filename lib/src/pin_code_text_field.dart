import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinCodeTextField extends StatefulWidget {
  final int length;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;
  final TextEditingController? controller;
  final bool obscureText;
  final BoxDecoration? pinBoxDecoration;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final double? cursorHeight;
  final double? cursorWidth;
  final EdgeInsets? padding;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool enabled;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const PinCodeTextField({
    Key? key,
    required this.length,
    this.onChanged,
    this.onCompleted,
    this.controller,
    this.obscureText = false,
    this.pinBoxDecoration,
    this.textStyle,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.padding,
    this.autofocus = false,
    this.focusNode,
    this.enabled = true,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
  }) : super(key: key);

  @override
  State<PinCodeTextField> createState() => _PinCodeTextFieldState();
}

class _PinCodeTextFieldState extends State<PinCodeTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late List<String> _pin;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _pin = List.filled(widget.length, '');
    
    _controller.addListener(() {
      setState(() {
        final text = _controller.text;
        _pin = List.filled(widget.length, '');
        for (int i = 0; i < text.length && i < widget.length; i++) {
          _pin[i] = text[i];
        }
      });

      if (_controller.text.length == widget.length) {
        widget.onCompleted?.call(_controller.text);
      }
      widget.onChanged?.call(_controller.text);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              widget.length,
              (index) => _buildPinBox(index),
            ),
          ),
        ),
        Opacity(
          opacity: 0,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: [
              LengthLimitingTextInputFormatter(widget.length),
              ...?widget.inputFormatters,
            ],
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            showCursor: false,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinBox(int index) {
    final isFocused = _focusNode.hasFocus && index == _controller.text.length;
    final hasValue = index < _controller.text.length;

    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: widget.pinBoxDecoration ??
          BoxDecoration(
            border: Border.all(
              color: isFocused ? Theme.of(context).primaryColor : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
      padding: widget.padding ?? const EdgeInsets.all(8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            widget.obscureText && hasValue ? '•' : _pin[index],
            style: widget.textStyle ??
                Theme.of(context).textTheme.headlineSmall,
          ),
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
