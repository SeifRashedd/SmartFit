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
          _controller!.value.isInitialized) {
        _startAutoCaptureCheck();
      }
    } catch (_) {}
  }

  bool _personFillsFrame(List<Map<String, double>> k) {
    if (k.length < 17) return false;

    // Require at least 4 of the 6 key body points to be detected with confidence
    const indices = [5, 6, 11, 12, 15, 16]; // shoulders, hips, ankles
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
      // Rescale if values are clearly in pixel space (0–192)
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

    // Use thresholds derived from AppConstants so they stay in sync with the
    // visual guide frame (personFillMinSpanY ≈ 0.74, personFillMinSpanX ≈ 0.23)
    return spanX > AppConstants.personFillMinSpanX &&
        spanY > AppConstants.personFillMinSpanY;
  }

  void _startAutoCaptureCheck() {
    _autoCheckTimer?.cancel();
    setState(() => _countdown = 5);
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted ||
          _controller == null ||
          !_controller!.value.isInitialized ||
          _isCapturing ||
          _frameFilled ||
          _isCheckingFrame ||
          !_poseModelLoaded) {
        return;
      }
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
        _isCapturing) {
      return;
    }
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
                      color: Colors.white.withValues(alpha: 0.8),
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

/// Realistic standing human silhouette drawn as a single bezier path.
/// Turns green when [filled] is true (person detected).
class _StandingSilhouettePainter extends CustomPainter {
  final bool filled;
  const _StandingSilhouettePainter({this.filled = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final color = filled ? const Color(0xFF00E676) : Colors.white70;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: filled ? 0.18 : 0.08)
      ..style = PaintingStyle.fill;

    void draw(Path p) {
      canvas.drawPath(p, fillPaint);
      canvas.drawPath(p, strokePaint);
    }

    // ── Key measurements (all relative to w / h) ────────────────────────────
    final headR = w * 0.125;
    final headCY = headR + h * 0.008;

    final neckHW = w * 0.068;
    final neckTopY = headCY + headR;
    final neckBotY = neckTopY + h * 0.038;

    // Shoulder to waist
    final shldrHW = w * 0.41;
    final shldrY = neckBotY + h * 0.005;
    final armpitY = shldrY + h * 0.018;
    final waistHW = w * 0.215;
    final waistY = shldrY + h * 0.305;

    // Hip and crotch
    final hipHW = w * 0.295;
    final hipY = waistY + h * 0.065;
    final crotchY = hipY + h * 0.058;
    final gapHW = w * 0.062; // half-gap between inner thighs

    // Arms (hanging naturally at ≈15° from torso)
    final armOutHW = shldrHW + w * 0.04;
    final armInHW = shldrHW - w * 0.08;
    final armBotY = waistY - h * 0.01;

    // Leg geometry (from center)
    final thighOutHW = gapHW + w * 0.095;
    final thighInHW = gapHW + w * 0.005;
    final kneeY = crotchY + h * 0.195;
    final kneeOutHW = gapHW + w * 0.085;
    final kneeInHW = gapHW + w * 0.008;
    final ankleY = h * 0.965;
    final ankleOutHW = gapHW + w * 0.068;
    final ankleInHW = gapHW + w * 0.001;

    // ── HEAD ────────────────────────────────────────────────────────────────
    draw(
      Path()
        ..addOval(Rect.fromCircle(center: Offset(cx, headCY), radius: headR)),
    );

    // ── FULL BODY (one closed path, clockwise from right of neck) ───────────
    // Sections: right neck → right shoulder → right arm outer → right wrist →
    //   right arm inner → right armpit → right torso → right hip →
    //   right outer thigh → right ankle outer → right ankle inner →
    //   right inner thigh → crotch arch →
    //   left inner thigh → left ankle inner → left ankle outer →
    //   left outer thigh → left hip → left torso → left armpit →
    //   left arm inner → left wrist → left arm outer → left shoulder →
    //   left neck → close across neck.
    final body = Path();

    // Start: right side of neck top
    body.moveTo(cx + neckHW, neckTopY);

    // Right neck → right shoulder
    body.cubicTo(
      cx + neckHW * 1.6,
      neckBotY,
      cx + shldrHW * 0.6,
      shldrY,
      cx + shldrHW,
      shldrY,
    );

    // Shoulder → arm outer (arm hangs slightly away)
    body.cubicTo(
      cx + armOutHW,
      shldrY + h * 0.06,
      cx + armOutHW,
      shldrY + h * 0.18,
      cx + armOutHW * 0.98,
      armBotY,
    );

    // Arm outer bottom → arm inner bottom (across wrist)
    body.lineTo(cx + armInHW, armBotY);

    // Arm inner → armpit (arm curves back toward body)
    body.cubicTo(
      cx + armInHW,
      armBotY - h * 0.04,
      cx + armInHW,
      armpitY + h * 0.02,
      cx + armInHW,
      armpitY,
    );

    // Armpit → right waist (ribcage curves in)
    body.cubicTo(
      cx + armInHW - w * 0.01,
      armpitY + h * 0.06,
      cx + waistHW + w * 0.02,
      waistY - h * 0.04,
      cx + waistHW,
      waistY,
    );

    // Right waist → right hip (flare out)
    body.cubicTo(
      cx + waistHW,
      waistY + (hipY - waistY) * 0.5,
      cx + hipHW - w * 0.01,
      hipY - h * 0.01,
      cx + hipHW,
      hipY,
    );

    // Right hip → right outer thigh top
    body.cubicTo(
      cx + hipHW,
      hipY + (crotchY - hipY) * 0.65,
      cx + thighOutHW + w * 0.01,
      crotchY - h * 0.005,
      cx + thighOutHW,
      crotchY,
    );

    // Right outer thigh → right outer knee
    body.cubicTo(
      cx + thighOutHW,
      crotchY + (kneeY - crotchY) * 0.35,
      cx + kneeOutHW,
      kneeY - h * 0.04,
      cx + kneeOutHW,
      kneeY,
    );

    // Right outer knee → right outer ankle
    body.cubicTo(
      cx + kneeOutHW,
      kneeY + (ankleY - kneeY) * 0.35,
      cx + ankleOutHW,
      ankleY - h * 0.05,
      cx + ankleOutHW,
      ankleY,
    );

    // Across right foot (outer → inner)
    body.lineTo(cx + ankleInHW, ankleY);

    // Right inner ankle → right inner knee
    body.cubicTo(
      cx + ankleInHW,
      ankleY - h * 0.05,
      cx + kneeInHW,
      kneeY + h * 0.04,
      cx + kneeInHW,
      kneeY,
    );

    // Right inner knee → right inner thigh (up to crotch)
    body.cubicTo(
      cx + kneeInHW,
      kneeY - h * 0.08,
      cx + thighInHW,
      crotchY + h * 0.02,
      cx + gapHW,
      crotchY,
    );

    // Crotch arch (gentle curve under the body)
    body.cubicTo(
      cx + gapHW * 0.3,
      crotchY + h * 0.022,
      cx - gapHW * 0.3,
      crotchY + h * 0.022,
      cx - gapHW,
      crotchY,
    );

    // Left inner thigh → left inner knee
    body.cubicTo(
      cx - thighInHW,
      crotchY + h * 0.02,
      cx - kneeInHW,
      kneeY - h * 0.08,
      cx - kneeInHW,
      kneeY,
    );

    // Left inner knee → left inner ankle
    body.cubicTo(
      cx - kneeInHW,
      kneeY + h * 0.04,
      cx - ankleInHW,
      ankleY - h * 0.05,
      cx - ankleInHW,
      ankleY,
    );

    // Across left foot (inner → outer)
    body.lineTo(cx - ankleOutHW, ankleY);

    // Left outer ankle → left outer knee
    body.cubicTo(
      cx - ankleOutHW,
      ankleY - h * 0.05,
      cx - kneeOutHW,
      kneeY + h * 0.04,
      cx - kneeOutHW,
      kneeY,
    );

    // Left outer knee → left outer thigh
    body.cubicTo(
      cx - kneeOutHW,
      kneeY - h * 0.04,
      cx - thighOutHW,
      crotchY + (kneeY - crotchY) * 0.35,
      cx - thighOutHW,
      crotchY,
    );

    // Left outer thigh → left hip
    body.cubicTo(
      cx - thighOutHW - w * 0.01,
      crotchY - h * 0.005,
      cx - hipHW,
      hipY + (crotchY - hipY) * 0.65,
      cx - hipHW,
      hipY,
    );

    // Left hip → left waist
    body.cubicTo(
      cx - hipHW + w * 0.01,
      hipY - h * 0.01,
      cx - waistHW,
      waistY + (hipY - waistY) * 0.5,
      cx - waistHW,
      waistY,
    );

    // Left waist → left armpit (ribcage back up)
    body.cubicTo(
      cx - waistHW - w * 0.02,
      waistY - h * 0.04,
      cx - armInHW + w * 0.01,
      armpitY + h * 0.06,
      cx - armInHW,
      armpitY,
    );

    // Left armpit → left arm inner bottom
    body.cubicTo(
      cx - armInHW,
      armpitY + h * 0.02,
      cx - armInHW,
      armBotY - h * 0.04,
      cx - armInHW,
      armBotY,
    );

    // Across left wrist (inner → outer)
    body.lineTo(cx - armOutHW * 0.98, armBotY);

    // Left arm outer → left shoulder
    body.cubicTo(
      cx - armOutHW,
      shldrY + h * 0.18,
      cx - armOutHW,
      shldrY + h * 0.06,
      cx - shldrHW,
      shldrY,
    );

    // Left shoulder → left neck
    body.cubicTo(
      cx - shldrHW * 0.6,
      shldrY,
      cx - neckHW * 1.6,
      neckBotY,
      cx - neckHW,
      neckTopY,
    );

    // Close across neck top
    body.close();

    draw(body);
  }

  @override
  bool shouldRepaint(covariant _StandingSilhouettePainter oldDelegate) =>
      oldDelegate.filled != filled;
}
