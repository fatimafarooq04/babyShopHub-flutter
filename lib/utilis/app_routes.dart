import 'package:babyshop/screens/admin-panel/Category.dart';
import 'package:babyshop/screens/admin-panel/alluser.dart';
import 'package:babyshop/screens/admin-panel/main_dashboard_screen.dart';
import 'package:babyshop/screens/admin-panel/product.dart';
import 'package:babyshop/screens/auth-ui/forgot_password.dart';
import 'package:babyshop/screens/auth-ui/signin_screen.dart';
import 'package:babyshop/screens/auth-ui/signup_screen.dart';
import 'package:babyshop/screens/auth-ui/splash_screen.dart';
import 'package:babyshop/screens/user-panel/main_screen.dart';
import 'package:get/get_navigation/get_navigation.dart';

class AppRoutes {
  static final pages = [
    // user routes
    GetPage(name: '/', page: () => SplashScreen()),
    GetPage(name: '/Signup', page: () => SignUp()),
    GetPage(name: '/Signin', page: () => SigninScreen()),
    GetPage(name: '/forgotPassword', page: () => ForgotPassword()),
    GetPage(name: '/mainPage', page: () => MainScreen()),

    // admin routes
    GetPage(name: '/admin', page: () => MainDashboardScreen()),
    GetPage(name: '/allUser', page: ()=>Alluser()),
    GetPage(name: '/category', page: ()=>Category()),
    GetPage(name: '/product', page: ()=>Product())


  ];
}
