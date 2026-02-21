import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartfit/core/services/camera_service.dart';
import 'package:smartfit/features/body_dect/model/body_detect_model.dart';

class BodyDetectView extends StatefulWidget {
  const BodyDetectView({super.key});

  @override
  State<BodyDetectView> createState() => _BodyDetectViewState();
}

class _BodyDetectViewState extends State<BodyDetectView> {
  final vm = BodyDetectModel();
  final CameraService _cameraService = CameraService();
  File? image;

  @override
  void initState() {
    super.initState();
    vm.init();
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    File? pickedImage;
    if (source == ImageSource.camera) {
      pickedImage = await _cameraService.captureImage();
    } else {
      pickedImage = await _cameraService.pickFromGallery();
    }

    if (pickedImage == null) return;

    setState(() {
      image = pickedImage;
    });

    await vm.analyzeBody(image!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Size Detection')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            image != null
                ? Image.file(image!, height: 250)
                : const Icon(Icons.accessibility, size: 200),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Select Image'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (vm.loading) const CircularProgressIndicator(),

            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            if (vm.topSize != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Size: ${vm.topSize}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bottom Size: ${vm.bottomSize}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Debug Info:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (vm.upperRatio != null)
                      Text(
                        'Upper Ratio: ${vm.upperRatio!.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    if (vm.lowerRatio != null)
                      Text(
                        'Lower Ratio: ${vm.lowerRatio!.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 4),
                    if (vm.shoulderWidth != null)
                      Text(
                        'Shoulder Width: ${vm.shoulderWidth!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (vm.hipWidth != null)
                      Text(
                        'Hip Width: ${vm.hipWidth!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (vm.torsoHeight != null)
                      Text(
                        'Torso Height: ${vm.torsoHeight!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    if (vm.legLength != null)
                      Text(
                        'Leg Length: ${vm.legLength!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
