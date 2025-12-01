import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  const MyTextfield({
    super.key,
    required this.controller,
    required this.text,
    required this.errorText,
    this.keyboardType,
    this.hintText,
    this.isPassword = false,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String text;
  final String errorText;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool isPassword;
  final IconData? prefixIcon;

  @override
  State<MyTextfield> createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.text,
        hintText: widget.hintText ?? widget.text,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.errorText;
        }
        return null;
      },
    );
  }
}
