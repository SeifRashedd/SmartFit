import 'dart:io';
import 'dart:typed_data';
import 'dart:developer';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PoseService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  /// Load MoveNet model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/4.tflite');

      // Log tensor shapes and types for debugging
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      log(
        'MoveNet Input shape: ${inputTensor.shape}, type: ${inputTensor.type}',
      );
      log(
        'MoveNet Output shape: ${outputTensor.shape}, type: ${outputTensor.type}',
      );

      _isModelLoaded = true;
    } catch (e) {
      log('Error loading MoveNet model: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  /// Run pose estimation and return 17 keypoints
  /// Each keypoint = {x, y, score}
  List<Map<String, double>> detectPose(File imageFile) {
    if (!_isModelLoaded || _interpreter == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      final input = _preprocess(imageFile);
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;

      // Create output buffer dynamically based on model output shape
      dynamic output;
      if (outputShape.length == 4) {
        // Shape: [1, 1, 17, 3] or [1, 17, 1, 3] etc.
        final batch = outputShape[0];
        final height = outputShape[1];
        final width = outputShape[2];
        final channels = outputShape[3];
        output = List.generate(
          batch,
          (_) => List.generate(
            height,
            (_) => List.generate(width, (_) => List.filled(channels, 0.0)),
          ),
        );
      } else if (outputShape.length == 3) {
        // Shape: [1, 17, 3]
        final batch = outputShape[0];
        final keypoints = outputShape[1];
        final coords = outputShape[2];
        output = List.generate(
          batch,
          (_) => List.generate(keypoints, (_) => List.filled(coords, 0.0)),
        );
      } else {
        throw Exception('Unexpected output shape: $outputShape');
      }

      _interpreter!.run(input, output);

      final keypoints = <Map<String, double>>[];

      // Handle different output shapes
      if (outputShape.length == 4) {
        // [1, 1, 17, 3] format
        for (int i = 0; i < 17; i++) {
          final y = (output[0][0][i][0] as num).toDouble();
          final x = (output[0][0][i][1] as num).toDouble();
          final score = (output[0][0][i][2] as num).toDouble();
          keypoints.add({'x': x, 'y': y, 'score': score});
        }
      } else if (outputShape.length == 3) {
        // [1, 17, 3] format
        for (int i = 0; i < 17; i++) {
          final y = (output[0][i][0] as num).toDouble();
          final x = (output[0][i][1] as num).toDouble();
          final score = (output[0][i][2] as num).toDouble();
          keypoints.add({'x': x, 'y': y, 'score': score});
        }
      }

      return keypoints;
    } catch (e) {
      log('Error detecting pose: $e');
      rethrow;
    }
  }

  /// Resize image for MoveNet (uint8 format: 0-255)
  List<dynamic> _preprocess(File file) {
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes)!;
    final resized = img.copyResize(image, width: 192, height: 192);

    // Use Uint8List since model expects uint8 input (0-255)
    final input = Uint8List(192 * 192 * 3);
    int index = 0;

    for (int y = 0; y < 192; y++) {
      for (int x = 0; x < 192; x++) {
        final pixel = resized.getPixel(x, y);
        // Use raw pixel values (0-255) instead of normalized (0.0-1.0)
        input[index++] = pixel.r.toInt();
        input[index++] = pixel.g.toInt();
        input[index++] = pixel.b.toInt();
      }
    }

    return input.reshape([1, 192, 192, 3]);
  }
}
