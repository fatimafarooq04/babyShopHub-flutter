import 'package:get/get.dart';

// bottom nav controller for naviagtion
class BottomNavController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
