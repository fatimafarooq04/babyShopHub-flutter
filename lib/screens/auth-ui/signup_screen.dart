import 'package:babyshop/controllers/authControllers/google_signin_controller.dart';
import 'package:babyshop/controllers/authControllers/signup_controller.dart';
import 'package:babyshop/utilis/app_constants.dart';
import 'package:babyshop/screens/user-panel/userWidget/custombutton.dart';
import 'package:babyshop/screens/user-panel/userWidget/ui_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:get/get.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Call  instance of signup controller
  final SignupController _signupController = Get.find<SignupController>();
  TextEditingController user = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  // Call instance of signup-with-google controller
  final GoogleSigninController _googleSigninController =
      Get.find<GoogleSigninController>();

  void signUp() async {
    try {
      UserCredential? userCredential = await _signupController.signUp(
        email.text.trim(),
        user.text.trim(),
        password.text.trim(),
      );

      //  Show verification snackbar if sign-up
      if (userCredential != null) {
        Get.snackbar(
          'Verification Required',
          'Check your email for verification',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppConstants.buttonBg,
          colorText: Colors.white,
        );

        //  Redirect to Sign In after a delay
        Future.delayed(Duration(seconds: 3), () {
          Get.toNamed('/Signin');
        });
      }
    } on FirebaseAuthException catch (e) {
      //  already use email
      if (e.code == 'email-already-in-use') {
        Get.snackbar(
          "Email Already in Use",
          "This email is already registered. Please log in instead.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        // Redirect to signin page if email already use
        Future.delayed(Duration(seconds: 3), () {
          Get.toNamed('/Signin');
        });
      } else {
        //  show if any error
        Get.snackbar(
          "Error",
          e.message ?? "An error occurred. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                spacer(),
                SizedBox(
                  width: 300,
                  child: RichText(
                    text: TextSpan(
                      text: 'Join',
                      style: TextStyle(fontSize: 20),
                      children: [
                        TextSpan(
                          text: ' BabyShopHub',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' and explore the best products for your little one!',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 50,
                  ),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        // username field
                        getTextFormField(
                          user,
                          'Username',

                          validator:
                              (value) => _signupController.validateUsername(
                                value ?? '',
                              ),
                        ),
                        spacer(),

                        // email field
                        getTextFormField(
                          email,
                          'Email',
                          validator:
                              (value) =>
                                  _signupController.validateEmail(value ?? ''),
                        ),
                        spacer(),

                        // password field
                        Obx(
                          () => getTextFormField(
                            password,
                            'Password',
                            validator:
                                (value) => _signupController.validatePassword(
                                  value ?? '',
                                ),
                            isobscure:
                                _signupController.isPasswordVisible.value,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _signupController.isPasswordVisible.toggle();
                              },
                              child:
                                  _signupController.isPasswordVisible.value
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                            ),
                          ),
                        ),
                        spacer(),
                        // confirm password field
                        Obx(
                          () => getTextFormField(
                            confirmPassword,
                            'Confirm Password',
                            validator:
                                (value) =>
                                    _signupController.validateConfirmPassword(
                                      value ?? '',
                                      password.text.trim(),
                                    ),
                            isobscure:
                                _signupController
                                    .isConfirmPasswordVisible
                                    .value,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _signupController.isConfirmPasswordVisible
                                    .toggle();
                              },
                              child:
                                  _signupController
                                          .isConfirmPasswordVisible
                                          .value
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Custombutton(
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              signUp();
                            }
                          },
                          text: 'Sign Up',
                          width: 400,
                        ),

                        spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account ',
                              style: TextStyle(fontSize: 20),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed('/Signin');
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 20,
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
                                  onTap: () {
                                    _googleSigninController
                                        .googleSignInAccount();
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
