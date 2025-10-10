import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareBottomSheet extends StatelessWidget {
  final String productId;
  final bool isDealer; // 👈 new flag

  const ShareBottomSheet({
    super.key,
    required this.productId,
    this.isDealer = false, // default user product
  });

  @override
  Widget build(BuildContext context) {
    /// ✅ URL decide karega ki dealer ka hai ya user ka
    final shareUrl = isDealer
        ? "http://oldmarket.bhoomi.cloud/api/dealers/$productId"
        : "http://oldmarket.bhoomi.cloud/product/$productId";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Share Product",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(color: AppColors.appGreen),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 25,
            runSpacing: 20,
            children: [
              _shareIcon(
                icon: FontAwesomeIcons.whatsapp,
                color: Colors.green,
                label: "WhatsApp",
                onTap: () => _launchCustomUrl(
                  "whatsapp://send?text=$shareUrl",
                  "WhatsApp not installed",
                ),
              ),
              _shareIcon(
                icon: FontAwesomeIcons.facebook,
                color: Colors.blue,
                label: "Facebook",
                onTap: () => _launchExternalUrl(
                  "https://www.facebook.com/sharer/sharer.php?u=$shareUrl",
                ),
              ),
              _shareIcon(
                icon: FontAwesomeIcons.telegram,
                color: Colors.blueAccent,
                label: "Telegram",
                onTap: () => _launchCustomUrl(
                  "tg://msg?text=$shareUrl",
                  "Telegram not installed",
                ),
              ),
              _shareIcon(
                icon: FontAwesomeIcons.instagram,
                color: Colors.purple,
                label: "Instagram",
                onTap: () => _launchCustomUrl(
                  "instagram://share?text=$shareUrl",
                  "Instagram not installed",
                ),
              ),
              _shareIcon(
                icon: Icons.sms,
                color: Colors.teal,
                label: "SMS",
                onTap: () => _launchCustomUrl(
                  "sms:?body=$shareUrl",
                  "SMS not supported",
                ),
              ),
              _shareIcon(
                icon: Icons.share,
                color: Colors.grey,
                label: "Others",
                onTap: () {
                  Share.share("Check this product: $shareUrl");
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Small reusable widget
  Widget _shareIcon({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 40),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _launchCustomUrl(String url, String errorMessage) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar("Error", errorMessage);
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
