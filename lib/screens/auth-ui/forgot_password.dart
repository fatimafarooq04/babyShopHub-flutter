import 'package:babyshop/controllers/forgot_password.dart';
import 'package:babyshop/widgets/custombutton.dart';
import 'package:babyshop/widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();
  ForgotPasswordController forgotPasswordController =
      Get.find<ForgotPasswordController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 160.0),
        child: SafeArea(
          child: Column(
            children: [
              Text(
                'Forgot Password',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              spacer(),
              Text(
                'It\'s okay reset your password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
              ),
              spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20,
                ),
                child: Form(
                  child: Column(
                    children: [getTextFormField(email, 'Enter email')],
                  ),
                ),
              ),
              spacer(),
              Custombutton(
                onPressed: () {
                  forgotPasswordController.forgotPassword(email.text.trim());
                },
                text: 'Send email',
                width: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
