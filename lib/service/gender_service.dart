import 'dart:io';
import 'dart:developer' as developer;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/image_preprocessor.dart';

class GenderService {
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    try {
      developer.log('[GenderService] Starting model loading...', name: 'GenderService');

      // Try with full path first, fallback to path without assets/ if needed
      final modelPath = 'assets/models/GenderClass_06_03-20-08.tflite';
      developer.log('[GenderService] Loading model from: $modelPath', name: 'GenderService');

      _interpreter = await Interpreter.fromAsset(modelPath);

      developer.log('[GenderService] Model loaded successfully!', name: 'GenderService');
      developer.log(
        '[GenderService] Input tensor count: ${_interpreter!.getInputTensors().length}',
        name: 'GenderService',
      );
      developer.log(
        '[GenderService] Output tensor count: ${_interpreter!.getOutputTensors().length}',
        name: 'GenderService',
      );

      _isModelLoaded = true;
      developer.log('[GenderService] Model initialization completed', name: 'GenderService');
    } catch (e, stackTrace) {
      developer.log('[GenderService] ERROR loading model: $e', name: 'GenderService', error: e, stackTrace: stackTrace);
      _isModelLoaded = false;
      rethrow;
    }
  }

  Map<String, dynamic> predictGender(File imageFile) {
    try {
      developer.log('[GenderService] Starting gender prediction...', name: 'GenderService');
      developer.log('[GenderService] Image file path: ${imageFile.path}', name: 'GenderService');
      developer.log('[GenderService] Image file exists: ${imageFile.existsSync()}', name: 'GenderService');

      if (!_isModelLoaded || _interpreter == null) {
        developer.log('[GenderService] ERROR: Model not loaded!', name: 'GenderService');
        throw Exception('Model not loaded. Call loadModel() first.');
      }

      developer.log('[GenderService] Preprocessing image...', name: 'GenderService');
      final input = preprocessImage(imageFile);
      developer.log('[GenderService] Image preprocessed. Input length: ${input.length}', name: 'GenderService');

      developer.log('[GenderService] Reshaping input buffer...', name: 'GenderService');
      final inputBuffer = input.reshape([1, 224, 224, 3]);
      developer.log('[GenderService] Input buffer shape: [1, 224, 224, 3]', name: 'GenderService');

      developer.log('[GenderService] Creating output buffer...', name: 'GenderService');
      final output = List.filled(2, 0.0).reshape([1, 2]);
      developer.log('[GenderService] Output buffer shape: [1, 2]', name: 'GenderService');

      developer.log('[GenderService] Running inference...', name: 'GenderService');
      final stopwatch = Stopwatch()..start();
      _interpreter!.run(inputBuffer, output);
      stopwatch.stop();
      developer.log('[GenderService] Inference completed in ${stopwatch.elapsedMilliseconds}ms', name: 'GenderService');

      final male = output[0][0];
      final female = output[0][1];
      developer.log('[GenderService] Raw predictions - Male: $male, Female: $female', name: 'GenderService');

      final result = male > female
          ? {'gender': 'male', 'confidence': male}
          : {'gender': 'female', 'confidence': female};

      developer.log(
        '[GenderService] Prediction result: ${result['gender']} (${(result['confidence']! * 100).toStringAsFixed(2)}%)',
        name: 'GenderService',
      );

      return result;
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
}
