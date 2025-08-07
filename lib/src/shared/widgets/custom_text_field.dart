import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final IconData icon;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool isEnabled;
  final bool isReadOnly;
  const CustomTextField({super.key, this.controller, this.focusNode, this.hintText, required this.icon, this.errorText, this.onChanged, this.isEnabled = true, this.isReadOnly = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: errorText != null ? Colors.red.shade300 : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        maxLength: 100,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          prefixIcon: Icon(icon, color: ColorConst.primaryBlue, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          counterText: '',
        ),
      ),
    );;
  }
}


Widget _buildErrorText(String error) {
  return Padding(
    padding: const EdgeInsets.only(top: 12.0),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade400, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            error,
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}