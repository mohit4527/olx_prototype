import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ads_controller.dart';
import '../../../services/apiServices/apiServices.dart';
import '../../../custom_widgets/shortVideoWidget.dart';

class ProfileUploadsScreen extends StatefulWidget {
  final String userId;
  final String mode; // 'products' or 'videos'
  const ProfileUploadsScreen({
    Key? key,
    required this.userId,
    required this.mode,
  }) : super(key: key);

  @override
  State<ProfileUploadsScreen> createState() => _ProfileUploadsScreenState();
}

class _ProfileUploadsScreenState extends State<ProfileUploadsScreen> {
  final AdsController controller = Get.put(AdsController());
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    if (widget.mode == 'products') {
      await controller.fetchProductsByUserId(widget.userId);
    } else {
      await controller.fetchVideosByUserId(widget.userId);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'products' ? 'Products' : 'Videos'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : widget.mode == 'products'
          ? Obx(() {
              final items = controller.profileProducts;
              if (items.isEmpty)
                return const Center(child: Text('No products'));
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, idx) {
                  final p = items[idx];
                  return ListTile(
                    leading: p.mediaUrl.isNotEmpty
                        ? Image.network(
                            ApiService().fullMediaUrl(p.mediaUrl.first),
                          )
                        : const Icon(Icons.image),
                    title: Text(p.title),
                    subtitle: Text(p.price.toString()),
                    onTap: () async {
                      await Get.toNamed(
                        '/description_screen',
                        arguments: {'carId': p.id},
                      );
                    },
                  );
                },
              );
            })
          : Obx(() {
              final vids = controller.profileVideos;
              if (vids.isEmpty) return const Center(child: Text('No videos'));
              return ListView.builder(
                itemCount: vids.length,
                itemBuilder: (_, idx) {
                  final v = vids[idx];
                  final url = ApiService().fullMediaUrl(v.videoUrl);
                  return Card(
                    child: ListTile(
                      leading: SizedBox(
                        width: 96,
                        height: 56,
                        child: VideoPlayerWidget(
                          videoUrl: url,
                          muted: true,
                          enableTapToToggle: true,
                        ),
                      ),
                      title: Text(v.title.isNotEmpty ? v.title : 'Video'),
                      subtitle: Text('${v.duration}s'),
                      onTap: () {
                        // open short video screen focused on this id
                        Get.toNamed('/shortVideo_screen', arguments: v.id);
                      },
                    ),
                  );
                },
              );
            }),
    );
  }
}
