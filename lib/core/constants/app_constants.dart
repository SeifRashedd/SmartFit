/// App-wide constants.
class AppConstants {
  static const String appName = 'Smart Fit';

  // Assets
  static const String genderModelAssetPath =
      'assets/models/GenderClass_06_03-20-08.tflite';

  // ── Body detection guide frame (on-screen overlay) ─────────────────────────

  /// Fraction of preview height the guide frame uses (0.0–1.0).
  static const double bodyGuideFrameHeightFraction = 0.92;

  /// Full-body guide aspect ratio: width / height (portrait standing person).
  static const double bodyGuideFrameAspectRatio = 0.45;

  // ── Auto-capture "frame-filled" thresholds ─────────────────────────────────
  // These are the MINIMUM keypoint spans (in MoveNet's 0–1 normalized space)
  // that must be detected before the auto-capture countdown starts.
  //
  // Rationale: the shoulder-width / body-height RATIO is scale-invariant,
  // so we only need to confirm the person is close enough for MoveNet to detect
  // a reasonable set of keypoints — NOT that they fill 74% of the screen.
  //
  // These values work for both adults and children standing at arm's length.

  /// Minimum nose→ankle vertical span (normalized 0–1).
  /// ≈ 0.38 means the person occupies at least ~38% of the image height.
  static const double personFillMinSpanY = 0.38;

  /// Minimum left→right horizontal keypoint span (normalized 0–1).
  /// ≈ 0.12 means shoulders are clearly separated in the frame.
  static const double personFillMinSpanX = 0.12;
}
