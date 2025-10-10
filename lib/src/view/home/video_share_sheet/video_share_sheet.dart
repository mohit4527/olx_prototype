import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoShareSheet {
  static void show(BuildContext context, String videoUrl) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1E1E2C),
                Color(0xFF232F34),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top indicator line
              Container(
                height: 4,
                width: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Share Video",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 25,
                  children: [
                    _buildShareButton(
                      icon: FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      label: "WhatsApp",
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://wa.me/?text=Check this out: $videoUrl"));
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.facebook,
                      color: Colors.blue,
                      label: "Facebook",
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://www.facebook.com/sharer/sharer.php?u=$videoUrl"));
                      },
                    ),
                    _buildShareButton(
                      icon: FontAwesomeIcons.instagram,
                      color: Colors.purple,
                      label: "Instagram",
                      onTap: () {
                        Share.share(videoUrl); // direct share
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.telegram,
                      color: Colors.lightBlue,
                      label: "Telegram",
                      onTap: () {
                        launchUrl(Uri.parse(
                            "https://t.me/share/url?url=$videoUrl&text=Check this!"));
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.sms,
                      color: Colors.orange,
                      label: "SMS",
                      onTap: () {
                        launchUrl(Uri.parse("sms:?body=$videoUrl"));
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.share,
                      color: Colors.white,
                      label: "Others",
                      onTap: () {
                        Share.share(videoUrl);
                      },
                    ),
                    _buildShareButton(
                      icon: Icons.copy,
                      color: Colors.grey,
                      label: "Copy",
                      onTap: () {
                        Share.share(videoUrl);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildShareButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 25),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
