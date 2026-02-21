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

      // MoveNet: coordinates are normalized 0.0–1.0; normalize if model used 0–192
      final kNorm = _normalizeKeypoints(k);

      // MoveNet keypoint order: 0 nose, 1 L eye, 2 R eye, 3 L ear, 4 R ear,
      // 5 L shoulder, 6 R shoulder, 7 L elbow, 8 R elbow, 9 L wrist, 10 R wrist,
      // 11 L hip, 12 R hip, 13 L knee, 14 R knee, 15 L ankle, 16 R ankle
      final nose = kNorm[0];
      final ls = kNorm[5];
      final rs = kNorm[6];
      final le = kNorm[7];
      final re = kNorm[8];
      final lw = kNorm[9];
      final rw = kNorm[10];
      final lh = kNorm[11];
      final rh = kNorm[12];
      final lk = kNorm[13];
      final rk = kNorm[14];
      final la = kNorm[15];
      final ra = kNorm[16];

      if (!_valid(ls, rs, lh, rh, la, ra)) {
        error = 'Please stand fully inside the frame';
        loading = false;
        notifyListeners();
        return;
      }

      // Full body height: nose to mid-ankle (all nodes scale)
      final avgAnkle = _avg(la, ra);
      final fullBodyHeight = _dist(nose, avgAnkle);
      if (fullBodyHeight == 0) {
        error = 'Unable to calculate body measurements. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // Upper body width from ALL upper nodes (shoulders, elbows, wrists)
      shoulderWidth = _dist(ls, rs);
      final elbowSpan = _dist(le, re);
      final wristSpan = _dist(lw, rw);
      double upperWidth = _combinedWidth(
        shoulderWidth!,
        elbowSpan,
        wristSpan,
        ls['score']!, rs['score']!, le['score']!, re['score']!, lw['score']!, rw['score']!,
      );

      // Lower body width from ALL lower nodes (hips, knees, ankles)
      hipWidth = _dist(lh, rh);
      final kneeSpan = _dist(lk, rk);
      final ankleSpan = _dist(la, ra);
      double lowerWidth = _combinedWidth(
        hipWidth!,
        kneeSpan,
        ankleSpan,
        lh['score']!, rh['score']!, lk['score']!, rk['score']!, la['score']!, ra['score']!,
      );

      final avgShoulder = _avg(ls, rs);
      final avgHip = _avg(lh, rh);
      torsoHeight = _dist(avgShoulder, avgHip);
      legLength = _dist(avgHip, avgAnkle);

      if (torsoHeight == 0 || legLength == 0) {
        error = 'Unable to calculate body measurements. Please try again.';
        loading = false;
        notifyListeners();
        return;
      }

      // Ratios: width / full body height (MoveNet 0–1 normalized)
      upperRatio = upperWidth / fullBodyHeight;
      lowerRatio = lowerWidth / fullBodyHeight;

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

  /// MoveNet docs: coords normalized 0–1. If model outputs 0–192, normalize.
  List<Map<String, double>> _normalizeKeypoints(List<Map<String, double>> k) {
    double maxVal = 0;
    for (final p in k) {
      if (p['x']! > maxVal) maxVal = p['x']!;
      if (p['y']! > maxVal) maxVal = p['y']!;
    }
    if (maxVal <= 1.0) return k;
    final scale = 1.0 / maxVal;
    return k.map((p) => {
      'x': p['x']! * scale,
      'y': p['y']! * scale,
      'score': p['score']!,
    }).toList();
  }

  Map<String, double> _avg(Map a, Map b) => {
    'x': (a['x']! + b['x']!) / 2,
    'y': (a['y']! + b['y']!) / 2,
  };

  double _dist(Map a, Map b) {
    return sqrt(pow(a['x']! - b['x']!, 2) + pow(a['y']! - b['y']!, 2));
  }

  /// Combine primary + optional spans (all nodes); include only when score good.
  double _combinedWidth(
    double primary,
    double span2,
    double span3,
    double s1a, double s1b, double s2a, double s2b, double s3a, double s3b,
  ) {
    double sum = primary;
    int n = 1;
    if (s2a > 0.25 && s2b > 0.25) {
      sum += span2;
      n++;
    }
    if (s3a > 0.25 && s3b > 0.25) {
      sum += span3;
      n++;
    }
    return sum / n;
  }

  // 🧥 TOP — calibrated for MoveNet 0–1 ratios (was under-predicting: M/S → aim L/XL)
  String _mapTopSize(double r) {
    if (r < 0.28) return 'S';
    if (r < 0.32) return 'M';
    if (r < 0.36) return 'L';
    if (r < 0.42) return 'XL';
    if (r < 0.48) return 'XXL';
    return 'XXXL';
  }

  // 👖 BOTTOM — same calibration
  String _mapBottomSize(double r) {
    if (r < 0.24) return 'S';
    if (r < 0.28) return 'M';
    if (r < 0.32) return 'L';
    if (r < 0.38) return 'XL';
    if (r < 0.44) return 'XXL';
    return 'XXXL';
  }
}
