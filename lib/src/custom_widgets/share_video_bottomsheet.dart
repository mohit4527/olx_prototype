import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';

class ShareBottomSheet extends StatelessWidget {
  final String videoId;

  const ShareBottomSheet({
    super.key,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    // Dummy user list (abhi ke liye hardcoded, API ke baad dynamic karenge)
    final dummyUsers = [
      {"name": "Rohit Sharma", "avatar": "https://i.pravatar.cc/150?img=1"},
      {"name": "Virat Kohli", "avatar": "https://i.pravatar.cc/150?img=2"},
      {"name": "Hardik Pandya", "avatar": "https://i.pravatar.cc/150?img=3"},
      {"name": "KL Rahul", "avatar": "https://i.pravatar.cc/150?img=4"},
      {"name": "Surya Kumar", "avatar": "https://i.pravatar.cc/150?img=5"},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          /// Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),

          /// Title
          const Text(
            "Share",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          /// Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),

          /// User List
          Expanded(
            child: ListView.builder(
              itemCount: dummyUsers.length,
              itemBuilder: (context, index) {
                final user = dummyUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user["avatar"]!),
                    radius: 24,
                  ),
                  title: Text(user["name"]!),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Get.snackbar("Shared", "Video shared with ${user["name"]}");
                    },
                    child: const Text("Send"),
                  ),
                );
              },
            ),
          ),

          /// Bottom Quick Share Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
                onPressed: () {
                  Get.snackbar("WhatsApp", "Shared on WhatsApp");
                },
              ),
              IconButton(
                icon: const Icon(Icons.facebook, color: Colors.blue),
                onPressed: () {
                  Get.snackbar("Facebook", "Shared on Facebook");
                },
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.instagram, color: Colors.purple),
                onPressed: () {
                  Get.snackbar("Instagram", "Shared on Instagram");
                },
              ),
              IconButton(
                icon: const Icon(Icons.link, color: Colors.grey),
                onPressed: () {
                  Get.snackbar("Link", "Copy link");
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
