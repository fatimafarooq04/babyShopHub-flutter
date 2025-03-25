import 'package:flutter/material.dart';
// when the user taps anywhere outside the TextField, the keyboard will automatically close!
class KeyboardFocus {
  static void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.requestFocus();
    }
  }
}
