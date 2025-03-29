import 'package:babyshop/utilis/app_constants.dart';
import 'package:flutter/material.dart';

TextFormField getTextFormField(
  TextEditingController controller,
  String text, {
  Widget? suffixIcon,
  Widget? prefixIcons,
  bool isobscure = false,
  String? Function(String?)? validator,
}) => TextFormField(
  autovalidateMode: AutovalidateMode.onUserInteraction,
  obscureText: isobscure,
  controller: controller,
  validator: validator,
  cursorColor: AppConstants.primaryColor,
  decoration: InputDecoration(
    fillColor: const Color.fromARGB(36, 154, 82, 255),
    filled: true,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcons,
    label: Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppConstants.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppConstants.outline),
    ),
  ),
);

SizedBox spacer() => SizedBox(height: 20);
