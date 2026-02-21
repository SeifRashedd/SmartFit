import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smartfit/core/constants/app_constants.dart';
import 'package:smartfit/features/body_dect/service/pose_service.dart';

/// Full-screen camera with a standing-person overlay.
/// Frame turns red when user fills the shape, then photo is taken automatically.
class BodyDetectGuidedCameraView extends StatefulWidget {
  const BodyDetectGuidedCameraView({super.key});

  @override
  State<BodyDetectGuidedCameraView> createState() =>
      _BodyDetectGuidedCameraViewState();
}

class _BodyDetectGuidedCameraViewState extends State<BodyDetectGuidedCameraView>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _useFrontCamera = false;
  bool _initialized = false;
  String? _error;
  bool _isCapturing = false;
  bool _isSwitchingCamera = false;
  bool _frameFilled = false;
  Timer? _autoCheckTimer;
  bool _isCheckingFrame = false;
  int _countdown = 5; // 5→1 then capture; reset to 5 if user leaves frame
  final PoseService _poseService = PoseService();
  bool _poseModelLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPoseModel();
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadPoseModel() async {
    try {
      await _poseService.loadModel();
      if (!mounted) return;
      setState(() => _poseModelLoaded = true);
      if (_initialized &&
          _controller != null &&
          _controller!.value.isInitialized)
        _startAutoCaptureCheck();
    } catch (_) {}
  }

  bool _personFillsFrame(List<Map<String, double>> k) {
    if (k.length < 17) return false;
    const indices = [5, 6, 11, 12, 15, 16];
    int valid = 0;
    for (final i in indices) {
      if (k[i]['score']! >= 0.3) valid++;
    }
    if (valid < 4) return false;
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final p in k) {
      if (p['score']! < 0.25) continue;
      double x = p['x']!;
      double y = p['y']!;
      if (x > 1.5 || y > 1.5) {
        x /= 192;
        y /= 192;
      }
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
    final spanX = maxX - minX;
    final spanY = maxY - minY;
    return spanX > 0.18 && spanY > 0.32;
  }

  void _startAutoCaptureCheck() {
    _autoCheckTimer?.cancel();
    setState(() => _countdown = 5);
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 1), (
      _,
    ) async {
      if (!mounted ||
          _controller == null ||
          !_controller!.value.isInitialized ||
          _isCapturing ||
          _frameFilled ||
          _isCheckingFrame ||
          !_poseModelLoaded)
        return;
      _isCheckingFrame = true;
      try {
        final xFile = await _controller!.takePicture();
        final file = File(xFile.path);
        final k = _poseService.detectPose(file);
        if (!mounted) return;
        final filled = _personFillsFrame(k);
        if (filled) {
          if (_countdown <= 1) {
            _autoCheckTimer?.cancel();
            setState(() => _frameFilled = true);
            await Future<void>.delayed(const Duration(milliseconds: 800));
            if (!mounted) return;
            Navigator.of(context).pop(file);
            return;
          }
          setState(() => _countdown = _countdown - 1);
        } else {
          setState(() => _countdown = 5);
        }
      } catch (_) {
        if (mounted) setState(() => _countdown = 5);
      }
      if (mounted) _isCheckingFrame = false;
    });
  }

  Future<void> _initCamera() async {
    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = 'No camera found';
          _initialized = true;
        });
        return;
      }
    }
    if (_cameras.isEmpty) {
      setState(() {
        _error = 'No camera found';
        _initialized = true;
      });
      return;
    }
    try {
      final direction = _useFrontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;
      final camera = _cameras.firstWhere(
        (c) => c.lensDirection == direction,
        orElse: () => _cameras.first,
      );
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _initialized = true;
        _error = null;
        _isSwitchingCamera = false;
      });
      if (_poseModelLoaded) _startAutoCaptureCheck();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Camera error: $e';
        _initialized = true;
        _isSwitchingCamera = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isSwitchingCamera) return;
    final oldController = _controller;
    setState(() {
      _isSwitchingCamera = true;
      _initialized = false;
      _controller = null;
    });
    await oldController?.dispose();
    _useFrontCamera = !_useFrontCamera;
    await _initCamera();
  }

  Future<void> _capture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing)
      return;
    setState(() => _isCapturing = true);
    try {
      final xFile = await _controller!.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(File(xFile.path));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCapturing = false;
        _error = 'Capture failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!_isSwitchingCamera &&
                _controller != null &&
                _controller!.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.previewSize?.height ?? 1,
                  height: _controller!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_controller!),
                ),
              )
            else if (_error != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            _buildGuideFrameOverlay(),
            if (_countdown >= 1 && _countdown <= 5 && !_frameFilled)
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        _frameFilled
                            ? 'Taking photo...'
                            : 'Stand in the outline — countdown resets if you move out',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_cameras.length > 1)
                      IconButton(
                        icon: Icon(
                          _useFrontCamera
                              ? Icons.camera_rear
                              : Icons.camera_front,
                          color: Colors.white,
                        ),
                        onPressed: _isSwitchingCamera ? null : _switchCamera,
                        tooltip: _useFrontCamera
                            ? 'Switch to back camera'
                            : 'Switch to selfie',
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            if (_initialized &&
                _error == null &&
                _controller != null &&
                !_frameFilled)
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: Text(
                    'Or tap to take photo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            if (_initialized && _error == null && _controller != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 48,
                child: Center(
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _isCapturing ? null : _capture,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: _isCapturing
                            ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.camera_alt, size: 32),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideFrameOverlay() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;
          final frameH = h * AppConstants.bodyGuideFrameHeightFraction;
          final frameW = frameH * AppConstants.bodyGuideFrameAspectRatio;
          final left = (w - frameW) / 2;
          final top = (h - frameH) / 2;
          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                width: frameW,
                height: frameH,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _StandingSilhouettePainter(filled: _frameFilled),
                    size: Size(frameW, frameH),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Clean standing person outline: arms out to sides, legs together (like reference).
class _StandingSilhouettePainter extends CustomPainter {
  final bool filled;

  _StandingSilhouettePainter({this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeColor = filled ? const Color(0xFFFF4444) : Colors.red;
    final strokeWidth = 3.0;
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Proportions: head, neck, shoulders (arms out), torso, legs together
    final headR = w * 0.18;
    final headTop = headR + 4;
    final neckBottom = headTop + headR + h * 0.04;
    final shoulderY = neckBottom + h * 0.02;
    final shoulderHalf = w * 0.38;
    final armOut = w * 0.12;
    final armDown = h * 0.12;
    final torsoBottom = shoulderY + h * 0.28;
    final waistHalf = w * 0.2;
    final hipY = torsoBottom + h * 0.04;
    final hipHalf = w * 0.16;
    final legBottom = h - 6;
    final legHalf = w * 0.06;

    // Head (circle)
    canvas.drawCircle(Offset(cx, headTop), headR, paint);
    // Neck
    canvas.drawLine(
      Offset(cx, headTop + headR),
      Offset(cx, shoulderY),
      paint,
    );
    // Shoulder line
    canvas.drawLine(
      Offset(cx - shoulderHalf, shoulderY),
      Offset(cx + shoulderHalf, shoulderY),
      paint,
    );
    // Arms out to sides, then down (slightly abducted, hands open)
    canvas.drawLine(
      Offset(cx - shoulderHalf, shoulderY),
      Offset(cx - shoulderHalf - armOut, shoulderY + armDown),
      paint,
    );
    canvas.drawLine(
      Offset(cx + shoulderHalf, shoulderY),
      Offset(cx + shoulderHalf + armOut, shoulderY + armDown),
      paint,
    );
    // Torso outline
    final torso = Path()
      ..moveTo(cx - shoulderHalf, shoulderY)
      ..quadraticBezierTo(
        cx - waistHalf,
        (shoulderY + torsoBottom) / 2,
        cx - waistHalf,
        torsoBottom,
      )
      ..lineTo(cx + waistHalf, torsoBottom)
      ..quadraticBezierTo(
        cx + waistHalf,
        (shoulderY + torsoBottom) / 2,
        cx + shoulderHalf,
        shoulderY,
      )
      ..close();
    canvas.drawPath(torso, paint);
    // Hips to legs (legs close together)
    canvas.drawLine(
      Offset(cx - waistHalf, torsoBottom),
      Offset(cx - hipHalf, hipY),
      paint,
    );
    canvas.drawLine(
      Offset(cx + waistHalf, torsoBottom),
      Offset(cx + hipHalf, hipY),
      paint,
    );
    canvas.drawLine(
      Offset(cx - hipHalf, hipY),
      Offset(cx - legHalf, legBottom),
      paint,
    );
    canvas.drawLine(
      Offset(cx + hipHalf, hipY),
      Offset(cx + legHalf, legBottom),
      paint,
    );

    final fillPaint = Paint()
      ..color = strokeColor.withOpacity(filled ? 0.15 : 0.06)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, headTop), headR, fillPaint);
    canvas.drawPath(torso, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _StandingSilhouettePainter oldDelegate) =>
      oldDelegate.filled != filled;
}
