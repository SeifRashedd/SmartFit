/// App-wide constants.
class AppConstants {
  static const String appName = 'Smart Fit';

  // Assets
  static const String genderModelAssetPath =
      'assets/models/GenderClass_06_03-20-08.tflite';

  // Body detection guide frame (on-screen overlay)
  // We do NOT need real-world dimensions (meters/inches). The box is a framing
  // guide: when the user fits their full body inside it, distance is normalized
  // and shoulder/hip ratios become comparable across users for S/M/L/XL.
  /// Fraction of preview height the guide frame uses (0.0–1.0).
  static const double bodyGuideFrameHeightFraction = 0.92;

  /// Full-body guide aspect ratio width/height (standing person).
  static const double bodyGuideFrameAspectRatio = 0.45;
}
