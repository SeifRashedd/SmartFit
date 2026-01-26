import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartfit/features/face_dect/model/gender_view_model.dart';

class GenderView extends StatefulWidget {
  const GenderView({super.key});

  @override
  State<GenderView> createState() => _GenderViewState();
}

class _GenderViewState extends State<GenderView> {
  final GenderViewModel _viewModel = GenderViewModel();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    developer.log('[GenderView] Widget initialized', name: 'GenderView');
    developer.log(
      '[GenderView] Initializing view model...',
      name: 'GenderView',
    );
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.init();
  }

  @override
  void dispose() {
    developer.log('[GenderView] Widget disposing...', name: 'GenderView');
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    developer.log(
      '[GenderView] View model changed, rebuilding UI...',
      name: 'GenderView',
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    try {
      developer.log(
        '[GenderView] Image picker button pressed',
        name: 'GenderView',
      );

      if (!_viewModel.isInitialized) {
        developer.log(
          '[GenderView] WARNING: Model not initialized, showing error',
          name: 'GenderView',
        );
        _showError('Model is still loading. Please wait...');
        return;
      }

      setState(() {
        _isLoading = true;
      });
      developer.log('[GenderView] Opening camera...', name: 'GenderView');

      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (picked == null) {
        developer.log(
          '[GenderView] User cancelled image selection',
          name: 'GenderView',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      developer.log(
        '[GenderView] Image selected: ${picked.path}',
        name: 'GenderView',
      );
      developer.log(
        '[GenderView] Image size: ${await File(picked.path).length()} bytes',
        name: 'GenderView',
      );

      setState(() {
        _image = File(picked.path);
        _isLoading = true;
      });
      developer.log(
        '[GenderView] Image file set, starting gender detection...',
        name: 'GenderView',
      );

      await _viewModel.detectGender(_image!);
      developer.log(
        '[GenderView] Gender detection completed',
        name: 'GenderView',
      );
    } catch (e, stackTrace) {
      developer.log(
        '[GenderView] ERROR during image picking: $e',
        name: 'GenderView',
        error: e,
        stackTrace: stackTrace,
      );
      _showError('Failed to pick image: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    developer.log('[GenderView] Showing error: $message', name: 'GenderView');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('[GenderView] Building widget...', name: 'GenderView');
    developer.log(
      '[GenderView] Image: ${_image?.path ?? "null"}',
      name: 'GenderView',
    );
    developer.log(
      '[GenderView] Model initialized: ${_viewModel.isInitialized}',
      name: 'GenderView',
    );
    developer.log(
      '[GenderView] Gender: ${_viewModel.gender ?? "null"}',
      name: 'GenderView',
    );
    developer.log('[GenderView] Loading: $_isLoading', name: 'GenderView');

    return Scaffold(
      appBar: AppBar(title: const Text('Gender Prediction Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_viewModel.isInitialized && _viewModel.errorMessage == null)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading ML model...'),
                  ],
                ),
              ),

            if (!_viewModel.isInitialized && _viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load model',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _viewModel.errorMessage ?? 'Unknown error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        developer.log(
                          '[GenderView] Retrying model initialization...',
                          name: 'GenderView',
                        );
                        _viewModel.init();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            if (_viewModel.isInitialized) ...[
              _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _image!,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.person, size: 200),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _pickImage,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Capture Image'),
              ),

              const SizedBox(height: 20),

              if (_viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Error: ${_viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_isLoading && _image != null)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Processing image...'),
                ),

              if (_viewModel.gender != null && !_isLoading)
                Column(
                  children: [
                    Text(
                      'Gender: ${_viewModel.gender!.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${(_viewModel.confidence! * 100).toStringAsFixed(2)}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
