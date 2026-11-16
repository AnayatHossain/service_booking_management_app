import 'package:flutter/material.dart';
import '../const/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final Color? labelColor;
  final Color? borderColor;
  final dynamic prefixIcon; // Accepts IconData or String asset path
  final IconData? prefixIconData;
  final bool isPassword;
  final bool? obscureText;
  final bool isPasswordVisible;
  final VoidCallback? onTogglePassword;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final dynamic suffixIcon; // Accepts Widget or IconData
  final String? hintText;
  final Function(String)? onChanged;
  final Function()? onTap;
  final bool readOnly;
  final bool enabled;
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
    this.obscureText,
    this.isPasswordVisible = false,
    this.onTogglePassword,
    this.onSuffixTap,
    this.keyboardType,
    this.validator,
    this.controller,
    this.suffixIcon,
    this.hintText,
    this.onChanged,
    this.readOnly = false,
    this.enabled = true,
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
    _obscure = widget.obscureText ?? widget.isPassword;
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _shouldObscure {
    if (widget.obscureText != null) return widget.obscureText!;
    if (!widget.isPassword) return false;
    if (widget.onTogglePassword != null) return !widget.isPasswordVisible;
    return _obscure;
  }

  Widget? _buildPrefix() {
    if (widget.prefixIconData != null) {
      return Icon(widget.prefixIconData,
          color: _focusNode.hasFocus ? AppColors.primaryColor : AppColors.textMuted, size: 20);
    }
    if (widget.prefixIcon is IconData) {
      return Icon(widget.prefixIcon as IconData,
          color: _focusNode.hasFocus ? AppColors.primaryColor : AppColors.textMuted, size: 20);
    }
    if (widget.prefixIcon is String) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(widget.prefixIcon as String, width: 20, height: 20),
      );
    }
    return null;
  }

  Widget? _buildSuffix() {
    if (widget.suffixIcon is Widget) return widget.suffixIcon as Widget;
    if (widget.suffixIcon is IconData) {
      return IconButton(
        icon: Icon(widget.suffixIcon as IconData, color: AppColors.textMuted, size: 20),
        onPressed: widget.onSuffixTap ?? widget.onTogglePassword,
      );
    }
    if (widget.isPassword || widget.obscureText != null) {
      return IconButton(
        icon: Icon(
          _shouldObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.textMuted,
          size: 20,
        ),
        onPressed: () {
          if (widget.onSuffixTap != null) {
            widget.onSuffixTap!();
          } else if (widget.onTogglePassword != null) {
            widget.onTogglePassword!();
          } else {
            setState(() {
              _obscure = !_obscure;
            });
          }
        },
      );
    }
    return null;
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
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            filled: true,
            fillColor: widget.enabled ? Colors.white : AppColors.bgColor,
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
            prefixIcon: _buildPrefix(),
            suffixIcon: _buildSuffix(),
          ),
        ),
      ],
    );
  }
}
