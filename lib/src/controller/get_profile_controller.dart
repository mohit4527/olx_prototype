
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GetProfileController extends GetxController {
  RxString imagePath = "".obs;

  Future getImageByCamera() async{
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: ImageSource.camera);
    if(image != null){
      imagePath.value = image.path.toString();
    }else{
      Get.snackbar("Error", "Please Pick any image first");
    }
  }

  Future getImageByGallery()async{
    final ImagePicker picking = ImagePicker();
    final images =await picking.pickImage(source: ImageSource.gallery);

    if(images != null){
      imagePath.value = images.path.toString();
    }else{
      Get.snackbar("Error", "Please select any photo");
    }
  }


}