import 'dart:io';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../utils/image_preprocessor.dart';

class GenderService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  FaceDetector? _faceDetector;

  Future<void> loadModel() async {
    try {
      developer.log(
        '[GenderService] Starting model loading...',
        name: 'GenderService',
      );

      // Try with full path first, fallback to path without assets/ if needed
      final modelPath = 'assets/models/GenderClass_06_03-20-08.tflite';
      developer.log(
        '[GenderService] Loading model from: $modelPath',
        name: 'GenderService',
      );

      _interpreter = await Interpreter.fromAsset(modelPath);

      developer.log(
        '[GenderService] Model loaded successfully!',
        name: 'GenderService',
      );
      developer.log(
        '[GenderService] Input tensor count: ${_interpreter!.getInputTensors().length}',
        name: 'GenderService',
      );
      developer.log(
        '[GenderService] Output tensor count: ${_interpreter!.getOutputTensors().length}',
        name: 'GenderService',
      );

      // Log tensor metadata to quickly diagnose "model doesn't work" issues.
      final in0 = _interpreter!.getInputTensors().first;
      final out0 = _interpreter!.getOutputTensors().first;
      developer.log(
        '[GenderService] Input[0] shape: ${in0.shape}, type: ${in0.type}',
        name: 'GenderService',
      );
      developer.log(
        '[GenderService] Output[0] shape: ${out0.shape}, type: ${out0.type}',
        name: 'GenderService',
      );

      _faceDetector ??= FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableLandmarks: false,
          enableClassification: false,
        ),
      );

      _isModelLoaded = true;
      developer.log(
        '[GenderService] Model initialization completed',
        name: 'GenderService',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[GenderService] ERROR loading model: $e',
        name: 'GenderService',
        error: e,
        stackTrace: stackTrace,
      );
      _isModelLoaded = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> predictGender(File imageFile) async {
    try {
      developer.log(
        '[GenderService] Starting gender prediction...',
        name: 'GenderService',
      );
      developer.log(
        '[GenderService] Image file path: ${imageFile.path}',
        name: 'GenderService',
      );
      developer.log(
        '[GenderService] Image file exists: ${imageFile.existsSync()}',
        name: 'GenderService',
      );

      if (!_isModelLoaded || _interpreter == null) {
        developer.log(
          '[GenderService] ERROR: Model not loaded!',
          name: 'GenderService',
        );
        throw Exception('Model not loaded. Call loadModel() first.');
      }

      final crop = await _detectLargestFaceCrop(imageFile);
      if (crop == null) {
        developer.log(
          '[GenderService] No face detected in image',
          name: 'GenderService',
        );
        throw Exception('No face detected. Please capture a clear face photo.');
      }

      developer.log(
        '[GenderService] Preprocessing image...',
        name: 'GenderService',
      );
      final input = preprocessImage(imageFile, crop: crop);
      developer.log(
        '[GenderService] Image preprocessed. Input length: ${input.length}',
        name: 'GenderService',
      );

      developer.log(
        '[GenderService] Reshaping input buffer...',
        name: 'GenderService',
      );
      final inputTensor = _interpreter!.getInputTensors().first;
      final inputShape = inputTensor.shape; // e.g. [1,224,224,3]
      final inputBuffer = input.reshape(inputShape);
      developer.log(
        '[GenderService] Input buffer shape: $inputShape',
        name: 'GenderService',
      );

      developer.log(
        '[GenderService] Creating output buffer...',
        name: 'GenderService',
      );
      final outputTensor = _interpreter!.getOutputTensors().first;
      final outputShape = outputTensor.shape;
      dynamic output;
      if (outputShape.length == 2 && outputShape[1] == 2) {
        output = List.filled(2, 0.0).reshape([1, 2]);
      } else if (outputShape.length == 2 && outputShape[1] == 1) {
        output = List.filled(1, 0.0).reshape([1, 1]);
      } else {
        // Fallback: create a flat buffer based on element count.
        final count = outputShape.fold<int>(1, (a, b) => a * b);
        output = List.filled(count, 0.0);
      }
      developer.log(
        '[GenderService] Output buffer shape: $outputShape',
        name: 'GenderService',
      );

      developer.log(
        '[GenderService] Running inference...',
        name: 'GenderService',
      );
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(inputBuffer, output);
      stopwatch.stop();
      developer.log(
        '[GenderService] Inference completed in ${stopwatch.elapsedMilliseconds}ms',
        name: 'GenderService',
      );

      final parsed = _parseGenderOutput(output, outputTensor.shape);
      developer.log(
        '[GenderService] Parsed prediction: $parsed',
        name: 'GenderService',
      );

      developer.log(
        '[GenderService] Prediction result: ${parsed['gender']} (${(parsed['confidence']! * 100).toStringAsFixed(2)}%)',
        name: 'GenderService',
      );

      return parsed;
    } catch (e, stackTrace) {
      developer.log(
        '[GenderService] ERROR during prediction: $e',
        name: 'GenderService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<math.Rectangle<int>?> _detectLargestFaceCrop(File imageFile) async {
    if (_faceDetector == null) {
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableLandmarks: false,
          enableClassification: false,
        ),
      );
    }

    developer.log(
      '[GenderService] Detecting face (ML Kit)...',
      name: 'GenderService',
    );
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final faces = await _faceDetector!.processImage(inputImage);
    developer.log(
      '[GenderService] Faces detected: ${faces.length}',
      name: 'GenderService',
    );
    if (faces.isEmpty) return null;

    // Pick the largest face and add a bit of margin so the crop contains the full face.
    Face best = faces.first;
    double bestArea = best.boundingBox.width * best.boundingBox.height;
    for (final f in faces.skip(1)) {
      final a = f.boundingBox.width * f.boundingBox.height;
      if (a > bestArea) {
        best = f;
        bestArea = a;
      }
    }

    final bb = best.boundingBox;
    final marginX = bb.width * 0.15;
    final marginY = bb.height * 0.25;
    final left = (bb.left - marginX).floor();
    final top = (bb.top - marginY).floor();
    final right = (bb.right + marginX).ceil();
    final bottom = (bb.bottom + marginY).ceil();
    return math.Rectangle<int>(left, top, right - left, bottom - top);
  }

  Map<String, dynamic> _parseGenderOutput(dynamic output, List<int> shape) {
    // Common cases:
    // - [1,2] => [male, female] (or reversed depending on training)
    // - [1,1] => probability of "male" (or "female") with sigmoid
    if (shape.length == 2 &&
        shape[1] == 2 &&
        output is List &&
        output.isNotEmpty) {
      final a = (output[0][0] as num).toDouble();
      final b = (output[0][1] as num).toDouble();
      developer.log(
        '[GenderService] Raw predictions - idx0: $a, idx1: $b',
        name: 'GenderService',
      );
      // Swap mapping because model outputs were reversed (idx0=female, idx1=male).
      return b > a
          ? {'gender': 'male', 'confidence': b}
          : {'gender': 'female', 'confidence': a};
    }

    if (shape.length == 2 &&
        shape[1] == 1 &&
        output is List &&
        output.isNotEmpty) {
      final p = (output[0][0] as num).toDouble();
      developer.log(
        '[GenderService] Raw prediction - p: $p',
        name: 'GenderService',
      );
      // Assumption: p is probability of male (0..1)
      final isMale = p >= 0.5;
      return {
        'gender': isMale ? 'male' : 'female',
        'confidence': isMale ? p : (1.0 - p),
      };
    }

    // Fallback: unknown output; just surface it.
    return {'gender': 'unknown', 'confidence': 0.0, 'raw': output};
  }
}
