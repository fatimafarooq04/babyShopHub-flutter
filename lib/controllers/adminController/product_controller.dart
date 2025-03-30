import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<XFile> finalImages = <XFile>[].obs;

  final ImagePicker picker = ImagePicker();
// pick image function 
  Future<void> pickImage() async {
    // select multiple images 
    final List<XFile>? selectedImage = await picker.pickMultiImage();
    if (selectedImage != null && selectedImage.isNotEmpty) {
      // print("Selected Images: ${selectedImage.map((e) => e.path).toList()}");
      // if image is not empty assign it to finalImages list 
      finalImages.assignAll(selectedImage);
    }
  }
  
  Future<void> productAdd()async{

  }

}
