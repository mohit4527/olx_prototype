import 'package:flutter/material.dart';

/// A utility widget that provides consistent error handling for network images
class SafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SafeNetworkImage({
    Key? key,
    required this.imageUrl,
    this.errorWidget,
    this.loadingWidget,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Widget defaultErrorWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 50,
      ),
    );

    final Widget defaultLoadingWidget = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );

    Widget imageWidget = Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return loadingWidget ?? defaultLoadingWidget;
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ SafeNetworkImage failed to load: $imageUrl');
        return errorWidget ?? defaultErrorWidget;
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}

/// Utility function to create a safe NetworkImage provider with fallback
ImageProvider safeNetworkImageProvider(String imageUrl) {
  return NetworkImage(imageUrl);
}

/// Extension to add safe network image functionality to existing Image.network calls
extension SafeImageNetworkX on Image {
  static Widget safenetwork(
    String src, {
    Key? key,
    double scale = 1.0,
    Widget? errorWidget,
    Widget? loadingWidget,
    BoxFit? fit,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return SafeNetworkImage(
      key: key,
      imageUrl: src,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
      fit: fit,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }
}
