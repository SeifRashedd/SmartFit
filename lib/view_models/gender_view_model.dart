import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:smartfit/service/gender_service.dart';

class GenderViewModel extends ChangeNotifier {
  final GenderService _service = GenderService();
  bool _isInitialized = false;
  String? _errorMessage;

  String? gender;
  double? confidence;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    try {
      developer.log('[GenderViewModel] Initializing view model...', name: 'GenderViewModel');

      if (_isInitialized) {
        developer.log('[GenderViewModel] Already initialized, skipping...', name: 'GenderViewModel');
        return;
      }

      developer.log('[GenderViewModel] Loading ML model...', name: 'GenderViewModel');
      await _service.loadModel();

      _isInitialized = true;
      _errorMessage = null;
      developer.log('[GenderViewModel] View model initialized successfully!', name: 'GenderViewModel');

      notifyListeners();
    } catch (e, stackTrace) {
      developer.log(
        '[GenderViewModel] ERROR during initialization: $e',
        name: 'GenderViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _errorMessage = 'Failed to initialize: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> detectGender(File image) async {
    try {
      developer.log('[GenderViewModel] Starting gender detection...', name: 'GenderViewModel');

      if (!_isInitialized) {
        developer.log('[GenderViewModel] WARNING: Not initialized, initializing now...', name: 'GenderViewModel');
        await init();
      }

      if (!_isInitialized) {
        developer.log('[GenderViewModel] ERROR: Failed to initialize model', name: 'GenderViewModel');
        _errorMessage = 'Model not initialized';
        notifyListeners();
        return;
      }

      developer.log('[GenderViewModel] Calling service to predict gender...', name: 'GenderViewModel');
      _errorMessage = null;
      final result = _service.predictGender(image);

      developer.log('[GenderViewModel] Prediction received: ${result['gender']}', name: 'GenderViewModel');

      gender = result['gender'] as String?;
      confidence = result['confidence'] as double?;

      developer.log(
        '[GenderViewModel] Gender: $gender, Confidence: ${confidence != null ? (confidence! * 100).toStringAsFixed(2) + "%" : "null"}',
        name: 'GenderViewModel',
      );
      developer.log('[GenderViewModel] Notifying listeners...', name: 'GenderViewModel');

      notifyListeners();
      developer.log('[GenderViewModel] Gender detection completed successfully', name: 'GenderViewModel');
    } catch (e, stackTrace) {
      developer.log(
        '[GenderViewModel] ERROR during gender detection: $e',
        name: 'GenderViewModel',
        error: e,
        stackTrace: stackTrace,
      );
      _errorMessage = 'Failed to detect gender: $e';
      gender = null;
      confidence = null;
      notifyListeners();
    }
  }
}
