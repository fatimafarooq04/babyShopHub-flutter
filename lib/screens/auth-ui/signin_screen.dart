import 'dart:developer';

import 'package:babyshop/controllers/authControllers/google_signin_controller.dart';
import 'package:babyshop/controllers/authControllers/signin_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final GoogleSigninController _controller = Get.find<GoogleSigninController>();
  final SigninController _signinController = Get.find<SigninController>();

  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 20,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 28,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                spacer(),
                SizedBox(
                  width: 250,
                  child: Text(
                    'Welcome back you\'ve been missed!',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 40,
                  ),
                  child: Form(
                    child: Column(
                      children: [
                        getTextFormField(email, 'Email'),
                        spacer(),
                        getTextFormField(
                          password,
                          'Password',
                          isobscure: obscure,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                            child:
                                obscure
                                    ? Icon(Icons.visibility_off)
                                    : Icon(Icons.visibility),
                          ),
                        ),
                        spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () {
                              Get.toNamed('forgotPassword');
                            },
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        spacer(),
                        Custombutton(
                          onPressed: () {
                            _signinController.signInMethod(
                              email.text.trim(),
                              password.text.trim(),
                            );
                          },
                          text: 'Sign in',
                          width: 400,
                        ),
                        spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create new account ',
                              style: TextStyle(fontSize: 20),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed("Signup");
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        spacer(),
                        Column(
                          children: [
                            Text(
                              'Or continue with',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                InkWell(
                                  onTap: () async {
                                    try {
                                      await _controller.googleSignInAccount();
                                    } catch (e) {
                                      log('Error$e');
                                    }
                                  },
                                  child: Image(
                                    image: Svg(
                                      'assets/images/icons8-google.svg',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                InkWell(
                                  onTap: () {},
                                  child: Image(
                                    image: Svg(
                                      'assets/images/icons8-facebook.svg',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
