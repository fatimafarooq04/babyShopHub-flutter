import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class GetUserDataController extends GetxController {
  Future<List<Map<String, dynamic>>> getUserData(String uid) async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('user')
            .where('id', isEqualTo: uid)
            .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
