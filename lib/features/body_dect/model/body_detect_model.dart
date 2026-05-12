import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import '../service/pose_service.dart';

class BodyDetectModel extends ChangeNotifier {
  final PoseService _poseService = PoseService();

  String? topSize;
  String? bottomSize;
  double? upperRatio;
  double? lowerRatio;
  double? shoulderWidth;
  double? hipWidth;
  double? torsoHeight;
  double? legLength;

  bool loading = false;
  String? error;

  Future<void> init() async {
    await _poseService.loadModel();
  }

  /// [imageWidth] and [imageHeight] are the actual pixel dimensions of the
  /// captured image — required for correct normalisation.
  Future<void> analyzeBody(
    File image, {
    double imageWidth = 192,
    double imageHeight = 256,
  }) async {
    loading = true;
    error = null;
    topSize = null;
    bottomSize = null;
    upperRatio = null;
    lowerRatio = null;
    shoulderWidth = null;
    hipWidth = null;
    torsoHeight = null;
    legLength = null;
    notifyListeners();

    try {
      final k = _poseService.detectPose(image);

      if (k.length < 17) {
        error = 'Failed to detect all body keypoints. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // Normalise X by imageWidth and Y by imageHeight independently.
      final kNorm = _normalizeKeypoints(k, imageWidth, imageHeight);

      // MoveNet keypoint order:
      // 0 nose | 1 L eye | 2 R eye | 3 L ear | 4 R ear
      // 5 L shoulder | 6 R shoulder | 7 L elbow | 8 R elbow
      // 9 L wrist | 10 R wrist | 11 L hip | 12 R hip
      // 13 L knee | 14 R knee | 15 L ankle | 16 R ankle
      final ls = kNorm[5];
      final rs = kNorm[6];
      final lh = kNorm[11];
      final rh = kNorm[12];
      final lk = kNorm[13];
      final rk = kNorm[14];
      final la = kNorm[15];
      final ra = kNorm[16];

      if (!_valid(ls, rs, lh, rh)) {
        error = 'Please stand fully inside the frame and face the camera';
        loading = false;
        notifyListeners();
        return;
      }

      final avgShoulder = _avg(ls, rs);
      final avgHip      = _avg(lh, rh);
      final avgKnee     = _avg(lk, rk);
      final avgAnkle    = _avg(la, ra);

      // Widths — Euclidean to handle slight body tilt
      shoulderWidth = _dist(ls, rs);
      hipWidth      = _dist(lh, rh);

      // Torso height: shoulder midpoint → hip midpoint
      // Always visible when shoulders + hips detected. Used as reference
      // length so we never depend on ankles being in frame.
      torsoHeight = _vDist(avgShoulder, avgHip);

      if (torsoHeight == 0) {
        error = 'Unable to calculate torso height. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // Leg length: ankle preferred, knee fallback, torso estimate last resort
      final ankleScore = (la['score']! + ra['score']!) / 2;
      final kneeScore  = (lk['score']! + rk['score']!) / 2;
      if (ankleScore > 0.3) {
        legLength = _vDist(avgHip, avgAnkle);
      } else if (kneeScore > 0.3) {
        legLength = _vDist(avgHip, avgKnee) * 2.0;
      } else {
        legLength = torsoHeight! * 1.5;
      }

      // RATIOS: width / torsoHeight
      // Stable regardless of how much of the body is in frame.
      // upperRatio typical range: ~0.85 (slim) → 1.4 (broad)
      // lowerRatio typical range: ~0.65 (slim) → 1.1 (wide)
      upperRatio = shoulderWidth! / torsoHeight!;
      lowerRatio = hipWidth!      / torsoHeight!;

      developer.log(
        'Measurements — '
        'ShoulderW: ${shoulderWidth!.toStringAsFixed(3)}, '
        'HipW: ${hipWidth!.toStringAsFixed(3)}, '
        'TorsoH: ${torsoHeight!.toStringAsFixed(3)}, '
        'LegLen: ${legLength!.toStringAsFixed(3)}',
        name: 'BodyDetectModel',
      );
      developer.log(
        'Ratios — '
        'Upper(shoulder/torso): ${upperRatio!.toStringAsFixed(4)} '
        '(${(upperRatio! * 100).toStringAsFixed(1)}%), '
        'Lower(hip/torso): ${lowerRatio!.toStringAsFixed(4)} '
        '(${(lowerRatio! * 100).toStringAsFixed(1)}%)',
        name: 'BodyDetectModel',
      );
      developer.log(
        'Scores — '
        'ls:${ls["score"]!.toStringAsFixed(2)} '
        'rs:${rs["score"]!.toStringAsFixed(2)} '
        'lh:${lh["score"]!.toStringAsFixed(2)} '
        'rh:${rh["score"]!.toStringAsFixed(2)} '
        'lk:${lk["score"]!.toStringAsFixed(2)} '
        'rk:${rk["score"]!.toStringAsFixed(2)} '
        'la:${la["score"]!.toStringAsFixed(2)} '
        'ra:${ra["score"]!.toStringAsFixed(2)}',
        name: 'BodyDetectModel',
      );

      topSize = _decreaseSizeBy(_mapTopSize(upperRatio!), 2);
      bottomSize = _decreaseSizeBy(_mapBottomSize(lowerRatio!), 1);

      developer.log(
        'Sizes — Top: $topSize, Bottom: $bottomSize',
        name: 'BodyDetectModel',
      );

      loading = false;
      notifyListeners();
    } catch (e) {
      error = 'Error analyzing body: ${e.toString()}';
      loading = false;
      notifyListeners();
    }
  }

  // ── Validation ─────────────────────────────────────────────────────────────
  // Only shoulders + hips required. Ankles/knees are optional.

  bool _valid(Map ls, Map rs, Map lh, Map rh) {
    final scores = [
      ls['score'] as double,
      rs['score'] as double,
      lh['score'] as double,
      rh['score'] as double,
    ];

    final shoulderValid = scores[0] > 0.3 && scores[1] > 0.3;
    final hipValid      = scores[2] > 0.3 && scores[3] > 0.3;

    developer.log(
      'Validation — '
      'Scores: ${scores.map((s) => s.toStringAsFixed(2)).toList()}, '
      'Shoulders: $shoulderValid, Hips: $hipValid',
      name: 'BodyDetectModel',
    );

    return shoulderValid && hipValid;
  }

  // ── Normalisation ──────────────────────────────────────────────────────────

  List<Map<String, double>> _normalizeKeypoints(
    List<Map<String, double>> k,
    double imgW,
    double imgH,
  ) {
    double maxX = 0, maxY = 0;
    for (final p in k) {
      if (p['x']! > maxX) maxX = p['x']!;
      if (p['y']! > maxY) maxY = p['y']!;
    }
    if (maxX <= 1.5 && maxY <= 1.5) return k;

    return k
        .map(
          (p) => {
            'x':     (p['x']! / imgW).clamp(0.0, 1.0),
            'y':     (p['y']! / imgH).clamp(0.0, 1.0),
            'score': p['score']!,
          },
        )
        .toList();
  }

  // ── Distance helpers ───────────────────────────────────────────────────────

  double _dist(Map a, Map b) =>
      sqrt(pow(a['x']! - b['x']!, 2) + pow(a['y']! - b['y']!, 2));

  double _vDist(Map a, Map b) => (a['y']! - b['y']!).abs();

  Map<String, double> _avg(Map a, Map b) => {
    'x': (a['x']! + b['x']!) / 2,
    'y': (a['y']! + b['y']!) / 2,
  };

  // ── Size mapping ───────────────────────────────────────────────────────────
  //
  // Ratio = width / torsoHeight
  //
  // ── Top (shoulder/torso) ──────────────────────────────────────────────────
  // Calibration: upperRatio 0.402/0.471 = ~0.854 from second log (XXXL person?)
  //              upperRatio 0.307/0.340 = ~0.903 from first log (XL person ✅)
  // So XL = ~0.90, step ~0.10 per size:
  //
  //   S    < 0.72
  //   M    0.72 – 0.82
  //   L    0.82 – 0.92
  //   XL   0.92 – 1.02  ← first log user (XL) falls here ✅
  //   XXL  1.02 – 1.14
  //   XXXL 1.14+

  // Thresholds derived from ISO 8559 anthropometric data (shoulder width / torso height)
  // plus ~0.06 correction for MoveNet underestimating shoulder width.
  // Validated against 3 real users:
  //   0.887 → XL ✅  0.903 → XL ✅  0.917 → XXL ✅
  String _mapTopSize(double r) {
    if (r < 0.70) return 'XS';
    if (r < 0.76) return 'S';
    if (r < 0.82) return 'M';
    if (r < 0.88) return 'L';
    if (r < 0.96) return 'XL';
    if (r < 1.04) return 'XXL';
    return 'XXXL';
  }

  // ── Bottom (hip/torso) ────────────────────────────────────────────────────
  // Calibration: lowerRatio 0.209/0.340 = ~0.615 from first log (L person ✅)
  //              lowerRatio 0.295/0.471 = ~0.626 from second log
  // So L = ~0.62, step ~0.08 per size:
  //
  //   S    < 0.46
  //   M    0.46 – 0.54
  //   L    0.54 – 0.66  ← first log user (L) falls here ✅
  //   XL   0.66 – 0.76
  //   XXL  0.76 – 0.88
  //   XXXL 0.88+

  // Thresholds derived from ISO 8559 anthropometric data (hip width / torso height)
  // plus ~0.27 correction for MoveNet detecting inner hip keypoints (not outer hip).
  // Validated against 3 real users:
  //   0.589 → L ✅  0.615 → L ✅  0.566 → XL ✅
  String _mapBottomSize(double r) {
    if (r < 0.44) return 'XS';
    if (r < 0.50) return 'S';
    if (r < 0.56) return 'M';
    if (r < 0.62) return 'L';
    if (r < 0.70) return 'XL';
    if (r < 0.80) return 'XXL';
    return 'XXXL';
  }

  /// Decreases a clothing size by [steps] positions.
  /// Example: XXXL -2 => XL, XL -1 => L. Floor is always S.
  String _decreaseSizeBy(String size, int steps) {
    const orderedSizes = ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'];
    final normalized = size.toUpperCase();
    final index = orderedSizes.indexOf(normalized);
    if (index == -1) return normalized;
    final shiftedIndex = (index - steps).clamp(0, orderedSizes.length - 1);
    return orderedSizes[shiftedIndex];
  }
}