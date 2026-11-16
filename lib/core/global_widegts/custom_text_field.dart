import 'package:flutter/material.dart';
import '../const/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final Color? labelColor;
  final Color? borderColor;
  final String? prefixIcon;
  final IconData? prefixIconData;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? hintText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;

  const CustomTextField({
    super.key,
    this.label,
    this.labelColor,
    this.borderColor,
    this.onTap,
    this.prefixIcon,
    this.prefixIconData,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.keyboardType,
    this.validator,
    this.controller,
    this.suffixIcon,
    this.hintText,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword;
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _useExternalToggle => widget.onTogglePassword != null;
  bool get _shouldObscure {
    if (!widget.isPassword) return false;
    return _useExternalToggle ? !widget.isPasswordVisible : _obscure;
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.labelColor ?? AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          onTap: widget.onTap,
          controller: widget.controller,
          focusNode: _focusNode,
          maxLength: widget.maxLength,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _shouldObscure,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.strokeColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.strokeColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: AppColors.error, width: 1.8),
            ),
            prefixIcon: widget.prefixIconData != null
                ? Icon(widget.prefixIconData, color: _focusNode.hasFocus ? AppColors.primaryColor : AppColors.textMuted, size: 20)
                : (widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(widget.prefixIcon!, width: 20, height: 20),
                      )
                    : null),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _shouldObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () {
                      if (_useExternalToggle) {
                        widget.onTogglePassword!();
                      } else {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      }
                    },
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
