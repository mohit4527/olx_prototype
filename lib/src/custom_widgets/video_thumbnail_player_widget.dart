// Stub implementation used while building on platforms where the
// native `video_thumbnail` plugin cannot be compiled. This keeps the
// app buildable; you can re-enable the real package in pubspec.yaml
// and restore the original implementation when the plugin is available.
import 'dart:typed_data';

class VideoThumbnailHelper {
  VideoThumbnailHelper._privateConstructor();
  static final VideoThumbnailHelper instance =
      VideoThumbnailHelper._privateConstructor();

  /// Returns null for now. Replace with the real plugin API when
  /// `video_thumbnail` is enabled in `pubspec.yaml`.
  Future<Uint8List?> getThumbnail(String videoUrl) async {
    // No-op stub: avoid calling native code during build.
    return null;
  }
}
