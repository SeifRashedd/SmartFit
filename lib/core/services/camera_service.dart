import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Capture image from camera
  Future<File?> captureImage({int imageQuality = 85}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Pick image from gallery
  Future<File?> pickFromGallery({int imageQuality = 85}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Show dialog to choose between camera and gallery
  Future<File?> pickImage({int imageQuality = 85}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
    );
    if (picked == null) return null;
    return File(picked.path);
  }
}
