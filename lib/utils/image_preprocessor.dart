import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:image/image.dart' as img;

Float32List preprocessImage(File file, {math.Rectangle<int>? crop}) {
  try {
    developer.log('[ImagePreprocessor] Starting image preprocessing...', name: 'ImagePreprocessor');
    developer.log('[ImagePreprocessor] File path: ${file.path}', name: 'ImagePreprocessor');

    developer.log('[ImagePreprocessor] Reading file bytes...', name: 'ImagePreprocessor');
    final bytes = file.readAsBytesSync();
    developer.log('[ImagePreprocessor] File size: ${bytes.length} bytes', name: 'ImagePreprocessor');

    developer.log('[ImagePreprocessor] Decoding image...', name: 'ImagePreprocessor');
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      developer.log('[ImagePreprocessor] ERROR: Failed to decode image', name: 'ImagePreprocessor');
      throw Exception('Failed to decode image');
    }

    // Normalize orientation based on EXIF so face boxes match pixel space more reliably.
    image = img.bakeOrientation(image);

    developer.log('[ImagePreprocessor] Original image size: ${image.width}x${image.height}', name: 'ImagePreprocessor');

    if (crop != null) {
      final safe = _clampRect(crop, image.width, image.height);
      developer.log(
        '[ImagePreprocessor] Cropping image to face box: '
        'left=${safe.left}, top=${safe.top}, w=${safe.width}, h=${safe.height}',
        name: 'ImagePreprocessor',
      );
      image = img.copyCrop(image, x: safe.left, y: safe.top, width: safe.width, height: safe.height);
      developer.log(
        '[ImagePreprocessor] Cropped image size: ${image.width}x${image.height}',
        name: 'ImagePreprocessor',
      );
    }

    developer.log('[ImagePreprocessor] Resizing image to 224x224...', name: 'ImagePreprocessor');
    image = img.copyResize(image, width: 224, height: 224);
    developer.log('[ImagePreprocessor] Image resized successfully', name: 'ImagePreprocessor');

    developer.log(
      '[ImagePreprocessor] Creating input buffer (224 * 224 * 3 = ${224 * 224 * 3} floats)...',
      name: 'ImagePreprocessor',
    );
    final input = Float32List(224 * 224 * 3);
    int index = 0;

    developer.log('[ImagePreprocessor] Processing pixels and normalizing...', name: 'ImagePreprocessor');
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);

        input[index++] = (pixel.r - 127.5) / 127.5;
        input[index++] = (pixel.g - 127.5) / 127.5;
        input[index++] = (pixel.b - 127.5) / 127.5;
      }
    }

    developer.log(
      '[ImagePreprocessor] Image preprocessing completed. Processed ${index ~/ 3} pixels',
      name: 'ImagePreprocessor',
    );
    developer.log(
      '[ImagePreprocessor] Sample normalized values - R: ${input[0]}, G: ${input[1]}, B: ${input[2]}',
      name: 'ImagePreprocessor',
    );

    return input;
  } catch (e, stackTrace) {
    developer.log(
      '[ImagePreprocessor] ERROR during preprocessing: $e',
      name: 'ImagePreprocessor',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
}

math.Rectangle<int> _clampRect(math.Rectangle<int> rect, int imageW, int imageH) {
  int left = rect.left.clamp(0, imageW - 1);
  int top = rect.top.clamp(0, imageH - 1);
  int right = (rect.left + rect.width).clamp(left + 1, imageW);
  int bottom = (rect.top + rect.height).clamp(top + 1, imageH);
  return math.Rectangle<int>(left, top, right - left, bottom - top);
}
