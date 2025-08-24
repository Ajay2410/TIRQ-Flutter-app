import 'package:flutter/material.dart';
import 'package:manager/resources/app_resources/app_resources.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final String? helperText;
  final String? errorText;

  const CommonTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.helperText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Text Field
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            helperText: helperText,
            errorText: errorText,
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.lightGray.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGray),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.lightGray.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

// Common validation functions
class CommonValidators {
  static String? Function(String?)? required(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? email(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? phone(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      if (value.length < 10) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? minLength(int minLength, String errorMessage) {
    return (value) {
      if (value == null || value.length < minLength) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? maxLength(int maxLength, String errorMessage) {
    return (value) {
      if (value != null && value.length > maxLength) {
        return errorMessage;
      }
      return null;
    };
  }

  static String? Function(String?)? pattern(RegExp pattern, String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return null; // Allow empty values, use required validator if needed
      }
      if (!pattern.hasMatch(value)) {
        return errorMessage;
      }
      return null;
    };
  }
}
