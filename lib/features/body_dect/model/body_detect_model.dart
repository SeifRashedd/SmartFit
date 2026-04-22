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
  Future<void> analyzeBody(File image,
      {double imageWidth = 192, double imageHeight = 256}) async {
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

      // ── FIX 1: Normalise X and Y by their OWN dimension ──────────────────
      // MoveNet outputs coordinates in the input tensor space (e.g. 192×192 or
      // 256×256). Dividing both axes by the same max value was wrong when the
      // image is not square — it distorted the Y axis.
      final kNorm = _normalizeKeypoints(k, imageWidth, imageHeight);

      // MoveNet keypoint order:
      // 0 nose | 1 L eye | 2 R eye | 3 L ear | 4 R ear
      // 5 L shoulder | 6 R shoulder | 7 L elbow | 8 R elbow
      // 9 L wrist | 10 R wrist | 11 L hip | 12 R hip
      // 13 L knee | 14 R knee | 15 L ankle | 16 R ankle
      final nose = kNorm[0];
      final ls   = kNorm[5];
      final rs   = kNorm[6];
      final lh   = kNorm[11];
      final rh   = kNorm[12];
      final la   = kNorm[15];
      final ra   = kNorm[16];

      if (!_valid(ls, rs, lh, rh, la, ra)) {
        error = 'Please stand fully inside the frame and face the camera';
        loading = false;
        notifyListeners();
        return;
      }

      final avgAnkle    = _avg(la, ra);
      final avgShoulder = _avg(ls, rs);
      final avgHip      = _avg(lh, rh);

      // ── FIX 2: Estimate top-of-head instead of using nose ────────────────
      // The nose sits ~10-15% below the top of the head. We estimate the head
      // top by going upward from the nose by half the nose-to-shoulder distance.
      final noseToShoulderV = _vDist(nose, avgShoulder);
      final headTopY        = nose['y']! - (noseToShoulderV * 0.5);
      final headTop         = {'x': nose['x']!, 'y': headTopY};

      final fullBodyHeight = _vDist(headTop, avgAnkle);
      if (fullBodyHeight == 0) {
        error = 'Unable to calculate body height. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // ── FIX 3: Use Euclidean distance for widths ──────────────────────────
      // Pure horizontal distance breaks when the person is even slightly
      // tilted. Euclidean handles mild tilt correctly.
      shoulderWidth = _dist(ls, rs);
      hipWidth      = _dist(lh, rh);

      torsoHeight = _vDist(avgShoulder, avgHip);
      legLength   = _vDist(avgHip, avgAnkle);

      if (torsoHeight == 0 && legLength == 0) {
        error = 'Unable to calculate body measurements. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // ── RATIOS: width / full body height (both in 0–1 normalised space) ──
      upperRatio = shoulderWidth! / fullBodyHeight;
      lowerRatio = hipWidth!      / fullBodyHeight;

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
      developer.log(
        'Keypoints — '
        'headTop:(${headTop["x"]!.toStringAsFixed(3)},${headTop["y"]!.toStringAsFixed(3)}) '
        'nose:(${nose["x"]!.toStringAsFixed(3)},${nose["y"]!.toStringAsFixed(3)}) '
        'ls:(${ls["x"]!.toStringAsFixed(3)},${ls["y"]!.toStringAsFixed(3)}) '
        'rs:(${rs["x"]!.toStringAsFixed(3)},${rs["y"]!.toStringAsFixed(3)}) '
        'lh:(${lh["x"]!.toStringAsFixed(3)},${lh["y"]!.toStringAsFixed(3)}) '
        'rh:(${rh["x"]!.toStringAsFixed(3)},${rh["y"]!.toStringAsFixed(3)}) '
        'la:(${la["x"]!.toStringAsFixed(3)},${la["y"]!.toStringAsFixed(3)}) '
        'ra:(${ra["x"]!.toStringAsFixed(3)},${ra["y"]!.toStringAsFixed(3)})',
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

  /// FIX 4: Use AND (&&) instead of OR (||) for shoulder and hip validation.
  /// Both shoulders AND both hips must be visible for accurate width measurement.
  bool _valid(Map ls, Map rs, Map lh, Map rh, Map la, Map ra) {
    final points = [ls, rs, lh, rh, la, ra];
    final scores = points.map((p) => p['score'] as double).toList();

    final validCount = scores.where((s) => s > 0.3).length;

    // Both shoulders must be clearly visible
    final shoulderValid = scores[0] > 0.3 && scores[1] > 0.3;
    // Both hips must be clearly visible
    final hipValid      = scores[2] > 0.3 && scores[3] > 0.3;

    developer.log(
      'Validation — '
      'Valid: $validCount/6, '
      'Scores: ${scores.map((s) => s.toStringAsFixed(2)).toList()}, '
      'Shoulders: $shoulderValid, '
      'Hips: $hipValid',
      name: 'BodyDetectModel',
    );

    return validCount >= 4 && shoulderValid && hipValid;
  }

  // ── Normalisation ──────────────────────────────────────────────────────────

  /// FIX 1 (core): Divide X by imageWidth and Y by imageHeight independently.
  /// Using a single maxCoord for both axes was wrong for non-square images and
  /// caused the Y axis to be scaled incorrectly.
  List<Map<String, double>> _normalizeKeypoints(
    List<Map<String, double>> k,
    double imgW,
    double imgH,
  ) {
    // Check if already normalised (all coords already in 0–1 range)
    double maxX = 0, maxY = 0;
    for (final p in k) {
      if (p['x']! > maxX) maxX = p['x']!;
      if (p['y']! > maxY) maxY = p['y']!;
    }
    if (maxX <= 1.5 && maxY <= 1.5) return k; // already normalised

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

  /// FIX 3: Euclidean distance — use for shoulder width, hip width.
  /// Handles slight body tilt that pure horizontal distance cannot.
  double _dist(Map a, Map b) =>
      sqrt(pow(a['x']! - b['x']!, 2) + pow(a['y']! - b['y']!, 2));

  /// Vertical distance only — still correct for body height, torso, legs.
  double _vDist(Map a, Map b) => (a['y']! - b['y']!).abs();

  Map<String, double> _avg(Map a, Map b) => {
    'x': (a['x']! + b['x']!) / 2,
    'y': (a['y']! + b['y']!) / 2,
  };

  // Horizontal-only kept for reference but no longer used in calculations.
  // ignore: unused_element
  double _hDist(Map a, Map b) => (a['x']! - b['x']!).abs();

  // ── Size mapping ───────────────────────────────────────────────────────────

  /// r = shoulderWidth (Euclidean) / bodyHeight (vertical, head-top to ankle)
  ///
  /// Standard real-world shoulder-to-height ratios:
  ///   Shoulder width is roughly 23–27% of body height for most adults.
  ///   - Slim / small frame : ~0.22–0.24
  ///   - Medium frame        : ~0.24–0.27
  ///   - Broad / large frame : ~0.28+
  ///
  /// Calibration tip: Log upperRatio for 5–10 real people of known sizes
  /// and adjust these thresholds to match your camera setup.
  String _mapTopSize(double r) {
    if (r < 0.22) return 'S';
    if (r < 0.25) return 'M';
    if (r < 0.28) return 'L';
    if (r < 0.31) return 'XL';
    if (r < 0.35) return 'XXL';
    return 'XXXL';
  }

  /// r = hipWidth (Euclidean) / bodyHeight (vertical, head-top to ankle)
  ///
  /// Hip-to-height ratio is typically slightly smaller than shoulder ratio:
  ///   - Slim : ~0.17–0.19
  ///   - Medium: ~0.19–0.23
  ///   - Large : ~0.24+
  String _mapBottomSize(double r) {
    if (r < 0.19) return 'S';
    if (r < 0.22) return 'M';
    if (r < 0.26) return 'L';
    if (r < 0.30) return 'XL';
    if (r < 0.34) return 'XXL';
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