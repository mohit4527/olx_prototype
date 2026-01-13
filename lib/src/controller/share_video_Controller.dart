import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareVideoController extends GetxController {
  static const String _assetBase = "https://oldmarket.bhoomi.cloud/";

  String getFullVideoUrl(String? path) {
    if (path == null || path.isEmpty) return _assetBase;
    final fixed = path.replaceAll("\\", "/");
    if (fixed.startsWith("http")) return fixed;
    final base = _assetBase.endsWith("/") ? _assetBase : "${_assetBase}/";
    final rel = fixed.startsWith("/") ? fixed.substring(1) : fixed;
    return "$base$rel";
  }

  Future<void> _launchOrShare(String url, String fallbackShare) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(fallbackShare);
    }
  }

  /// WhatsApp
  Future<void> shareToWhatsApp(String videoPathOrUrl) async {
    final full = getFullVideoUrl(videoPathOrUrl);
    final url = "https://wa.me/?text=${Uri.encodeComponent(full)}";
    await _launchOrShare(url, full);
  }

  /// Facebook
  Future<void> shareToFacebook(String videoPathOrUrl) async {
    final full = getFullVideoUrl(videoPathOrUrl);
    final url =
        "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(full)}";
    await _launchOrShare(url, full);
  }

  /// Telegram
  Future<void> shareToTelegram(String videoPathOrUrl) async {
    final full = getFullVideoUrl(videoPathOrUrl);
    final url = "https://t.me/share/url?url=${Uri.encodeComponent(full)}";
    await _launchOrShare(url, full);
  }

  /// SMS
  Future<void> shareToSMS(String videoPathOrUrl) async {
    final full = getFullVideoUrl(videoPathOrUrl);
    final url = "sms:?body=${Uri.encodeComponent(full)}";
    await _launchOrShare(url, full);
  }

  /// Instagram (no direct deep link for URLs) -> generic share
  Future<void> shareToInstagram(String videoPathOrUrl) async {
    final full = getFullVideoUrl(videoPathOrUrl);
    await Share.share(full);
  }

  /// Others
  Future<void> shareOthers(String videoPathOrUrl) async {
    final full = getFullVideoUrl(videoPathOrUrl);
    await Share.share(full);
  }
}
