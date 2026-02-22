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

  Future<void> analyzeBody(File image) async {
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

      // MoveNet: coordinates are normalized 0.0–1.0; rescale if model outputs 0–192
      final kNorm = _normalizeKeypoints(k);

      // MoveNet keypoint order: 0 nose, 1 L eye, 2 R eye, 3 L ear, 4 R ear,
      // 5 L shoulder, 6 R shoulder, 7 L elbow, 8 R elbow, 9 L wrist, 10 R wrist,
      // 11 L hip, 12 R hip, 13 L knee, 14 R knee, 15 L ankle, 16 R ankle
      final nose = kNorm[0];
      final ls = kNorm[5];
      final rs = kNorm[6];
      final lh = kNorm[11];
      final rh = kNorm[12];
      final la = kNorm[15];
      final ra = kNorm[16];

      if (!_valid(ls, rs, lh, rh, la, ra)) {
        error = 'Please stand fully inside the frame';
        loading = false;
        notifyListeners();
        return;
      }

      final avgAnkle = _avg(la, ra);
      final avgShoulder = _avg(ls, rs);
      final avgHip = _avg(lh, rh);

      // ── HEIGHT: vertical (Y-axis) only ──────────────────────────────────────
      // MoveNet: Y increases downward → ankle_y > nose_y for a standing person
      final fullBodyHeight = _vDist(nose, avgAnkle);
      if (fullBodyHeight == 0) {
        error = 'Unable to calculate body measurements. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // ── WIDTHS: horizontal (X-axis) only ────────────────────────────────────
      // Using shoulder-to-shoulder for tops, hip-to-hip for bottoms.
      // Elbows/wrists are NOT averaged in: they reflect arm position, not body width.
      shoulderWidth = _hDist(ls, rs);
      hipWidth = _hDist(lh, rh);

      torsoHeight = _vDist(avgShoulder, avgHip);
      legLength = _vDist(avgHip, avgAnkle);

      if (torsoHeight == 0 && legLength == 0) {
        error = 'Unable to calculate body measurements. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // ── RATIOS: width / full body height (both in 0–1 normalized space) ─────
      upperRatio = shoulderWidth! / fullBodyHeight;
      lowerRatio = hipWidth! / fullBodyHeight;

      developer.log(
        'Measurements — '
        'BodyHeight: ${fullBodyHeight.toStringAsFixed(3)}, '
        'ShoulderW: ${shoulderWidth!.toStringAsFixed(3)}, '
        'HipW: ${hipWidth!.toStringAsFixed(3)}, '
        'TorsoH: ${torsoHeight!.toStringAsFixed(3)}, '
        'LegLen: ${legLength!.toStringAsFixed(3)}',
        name: 'BodyDetectModel',
      );
      developer.log(
        'Ratios — '
        'Upper(shoulder/height): ${upperRatio!.toStringAsFixed(4)} '
        '(${(upperRatio! * 100).toStringAsFixed(1)}%), '
        'Lower(hip/height): ${lowerRatio!.toStringAsFixed(4)} '
        '(${(lowerRatio! * 100).toStringAsFixed(1)}%)',
        name: 'BodyDetectModel',
      );
      // Keypoint summary for calibration
      developer.log(
        'Keypoints — '
        'nose:(${nose["x"]!.toStringAsFixed(3)},${nose["y"]!.toStringAsFixed(3)}) '
        'ls:(${ls["x"]!.toStringAsFixed(3)},${ls["y"]!.toStringAsFixed(3)}) '
        'rs:(${rs["x"]!.toStringAsFixed(3)},${rs["y"]!.toStringAsFixed(3)}) '
        'lh:(${lh["x"]!.toStringAsFixed(3)},${lh["y"]!.toStringAsFixed(3)}) '
        'rh:(${rh["x"]!.toStringAsFixed(3)},${rh["y"]!.toStringAsFixed(3)}) '
        'la:(${la["x"]!.toStringAsFixed(3)},${la["y"]!.toStringAsFixed(3)}) '
        'ra:(${ra["x"]!.toStringAsFixed(3)},${ra["y"]!.toStringAsFixed(3)})',
        name: 'BodyDetectModel',
      );

      topSize = _mapTopSize(upperRatio!);
      bottomSize = _mapBottomSize(lowerRatio!);

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

  bool _valid(Map a, Map b, Map c, Map d, Map e, Map f) {
    final points = [a, b, c, d, e, f];
    final scores = points.map((p) => p['score'] as double).toList();

    final validCount = scores.where((s) => s > 0.3).length;
    final shoulderValid = scores[0] > 0.3 || scores[1] > 0.3;
    final hipValid = scores[2] > 0.3 || scores[3] > 0.3;

    developer.log(
      'Validation — Valid: $validCount/6, Shoulders: $shoulderValid, Hips: $hipValid',
      name: 'BodyDetectModel',
    );

    return validCount >= 4 && shoulderValid && hipValid;
  }

  // ── Normalisation ──────────────────────────────────────────────────────────

  /// MoveNet Lightning/Thunder outputs coords already in [0,1].
  /// Only rescale when the values are clearly in pixel space (max > 1.5).
  List<Map<String, double>> _normalizeKeypoints(List<Map<String, double>> k) {
    double maxCoord = 0;
    for (final p in k) {
      if (p['x']! > maxCoord) maxCoord = p['x']!;
      if (p['y']! > maxCoord) maxCoord = p['y']!;
    }
    if (maxCoord <= 1.5) return k; // already normalized
    return k
        .map(
          (p) => {
            'x': (p['x']! / maxCoord).clamp(0.0, 1.0),
            'y': (p['y']! / maxCoord).clamp(0.0, 1.0),
            'score': p['score']!,
          },
        )
        .toList();
  }

  // ── Distance helpers ───────────────────────────────────────────────────────

  /// Horizontal distance only (for widths: shoulder, hip, etc.)
  double _hDist(Map a, Map b) => (a['x']! - b['x']!).abs();

  /// Vertical distance only (for heights: body height, torso, legs)
  double _vDist(Map a, Map b) => (a['y']! - b['y']!).abs();

  Map<String, double> _avg(Map a, Map b) => {
    'x': (a['x']! + b['x']!) / 2,
    'y': (a['y']! + b['y']!) / 2,
  };

  // Keep Euclidean for any diagonal measurements if needed elsewhere
  // ignore: unused_element
  double _dist(Map a, Map b) =>
      sqrt(pow(a['x']! - b['x']!, 2) + pow(a['y']! - b['y']!, 2));

  // ── Size mapping ───────────────────────────────────────────────────────────

  /// r = shoulderWidth / bodyHeight (both horizontal-only, normalized 0–1 coords)
  ///
  /// These thresholds are derived from real-world MoveNet observations:
  ///   A typical adult standing at arm's length from camera:
  ///   - Shoulder span ≈ 20–35% of body height
  ///   - Children and slim adults: lower end (~0.20)
  ///   - Broad/large adults: higher end (~0.35+)
  ///
  /// If the range feels off after testing, log upperRatio and adjust here.
  String _mapTopSize(double r) {
    if (r < 0.20) return 'S';
    if (r < 0.24) return 'M';
    if (r < 0.28) return 'L';
    if (r < 0.33) return 'XL';
    if (r < 0.38) return 'XXL';
    return 'XXXL';
  }

  /// r = hipWidth / bodyHeight (both horizontal-only, normalized 0–1 coords)
  String _mapBottomSize(double r) {
    if (r < 0.17) return 'S';
    if (r < 0.21) return 'M';
    if (r < 0.25) return 'L';
    if (r < 0.30) return 'XL';
    if (r < 0.35) return 'XXL';
    return 'XXXL';
  }
}
