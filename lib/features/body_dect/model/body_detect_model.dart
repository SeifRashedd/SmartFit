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

      final ls = k[5]; // left shoulder
      final rs = k[6]; // right shoulder
      final lh = k[11]; // left hip
      final rh = k[12]; // right hip
      final la = k[15]; // left ankle
      final ra = k[16]; // right ankle

      // Log keypoint scores for debugging
      developer.log(
        'Keypoint scores - LS: ${ls['score']}, RS: ${rs['score']}, '
        'LH: ${lh['score']}, RH: ${rh['score']}, '
        'LA: ${la['score']}, RA: ${ra['score']}',
        name: 'BodyDetectModel',
      );

      if (!_valid(ls, rs, lh, rh, la, ra)) {
        error = 'Please stand fully inside the frame';
        loading = false;
        notifyListeners();
        return;
      }

      // Calculate widths, using fallback if one side has low confidence
      shoulderWidth = _calculateWidth(ls, rs);
      hipWidth = _calculateWidth(lh, rh);

      final avgShoulder = _avg(ls, rs);
      final avgHip = _avg(lh, rh);
      final avgAnkle = _avg(la, ra);

      torsoHeight = _dist(avgShoulder, avgHip);
      legLength = _dist(avgHip, avgAnkle);

      if (torsoHeight == 0 || legLength == 0) {
        error = 'Unable to calculate body measurements. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      upperRatio = shoulderWidth! / torsoHeight!;
      lowerRatio = hipWidth! / legLength!;

      // Log all measurements for debugging
      developer.log(
        'Measurements - Shoulder Width: ${shoulderWidth!.toStringAsFixed(2)}, '
        'Hip Width: ${hipWidth!.toStringAsFixed(2)}, '
        'Torso Height: ${torsoHeight!.toStringAsFixed(2)}, '
        'Leg Length: ${legLength!.toStringAsFixed(2)}',
        name: 'BodyDetectModel',
      );
      developer.log(
        'Ratios - Upper: ${upperRatio!.toStringAsFixed(4)}, '
        'Lower: ${lowerRatio!.toStringAsFixed(4)}',
        name: 'BodyDetectModel',
      );

      topSize = _mapTopSize(upperRatio!);
      bottomSize = _mapBottomSize(lowerRatio!);

      developer.log(
        'Sizes - Top: $topSize, Bottom: $bottomSize',
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

  bool _valid(Map a, Map b, Map c, Map d, Map e, Map f) {
    final points = [a, b, c, d, e, f];
    final scores = points.map((p) => p['score']!).toList();

    // Require at least 4 out of 6 keypoints to have score > 0.3
    // This is more lenient and allows for partial occlusion
    final validCount = scores.where((s) => s > 0.3).length;

    // Also check that critical pairs (shoulders, hips) have at least one valid point
    final shoulderValid = scores[0] > 0.3 || scores[1] > 0.3; // ls or rs
    final hipValid = scores[2] > 0.3 || scores[3] > 0.3; // lh or rh

    developer.log(
      'Validation - Valid count: $validCount/6, Shoulders: $shoulderValid, Hips: $hipValid',
      name: 'BodyDetectModel',
    );

    return validCount >= 4 && shoulderValid && hipValid;
  }

  Map<String, double> _avg(Map a, Map b) => {
    'x': (a['x']! + b['x']!) / 2,
    'y': (a['y']! + b['y']!) / 2,
  };

  double _dist(Map a, Map b) {
    return sqrt(pow(a['x']! - b['x']!, 2) + pow(a['y']! - b['y']!, 2));
  }

  /// Calculate width between two points, with fallback if one has low confidence
  double _calculateWidth(Map a, Map b) {
    final scoreA = a['score']!;
    final scoreB = b['score']!;

    // If both have good confidence, use distance
    if (scoreA > 0.3 && scoreB > 0.3) {
      return _dist(a, b);
    }

    // If only one has good confidence, still use distance but log a warning
    // The distance calculation will still work, just may be less accurate
    if (scoreA > 0.3 || scoreB > 0.3) {
      developer.log(
        'Warning: One keypoint has low confidence (A: $scoreA, B: $scoreB)',
        name: 'BodyDetectModel',
      );
      return _dist(a, b);
    }

    // If both are low confidence, still return distance (validation should catch this)
    return _dist(a, b);
  }

  // 🧥 TOP (Shirts / Jackets)
  String _mapTopSize(double r) {
    if (r < 0.38) return 'S';
    if (r < 0.42) return 'M';
    if (r < 0.46) return 'L';
    if (r < 0.50) return 'XL';
    if (r < 0.54) return 'XXL';
    return 'XXXL';
  }

  // 👖 BOTTOM (Jeans / Pants)
  String _mapBottomSize(double r) {
    if (r < 0.34) return 'S';
    if (r < 0.38) return 'M';
    if (r < 0.42) return 'L';
    if (r < 0.46) return 'XL';
    if (r < 0.50) return 'XXL';
    return 'XXXL';
  }
}
