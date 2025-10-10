import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../controller/short_video_controller.dart';
import '../../../custom_widgets/share_video_bottomsheet.dart';
import '../../../custom_widgets/shortVideoWidget.dart';
import '../../../model/short_video_model/short_video_model.dart';
import '../video_uploadScreen/video_uploadScreen.dart';
import '../../../services/apiServices/apiServices.dart';

class ShortVideoScreen extends StatefulWidget {
  ShortVideoScreen({Key? key}) : super(key: key);

  @override
  State<ShortVideoScreen> createState() => _ShortVideoScreenState();
}

class _ShortVideoScreenState extends State<ShortVideoScreen> {
  final ShortVideoController controller = Get.put(ShortVideoController());
  late PageController _pageCtrl;
  int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    // Determine if an initial video id was passed
    final arg = Get.arguments;
    print('[ShortVideoScreen] initState: raw Get.arguments => $arg');
    bool didJump = false;
    if (arg != null) {
      try {
        String? vid;
        List<dynamic>? inlineVideos;
        int? inlineIndex;

        if (arg is String) {
          vid = arg;
        } else if (arg is Map) {
          // Accept either an id or a supplied videos list + currentIndex
          vid =
              arg['id']?.toString() ??
              arg['videoId']?.toString() ??
              arg['video']?.toString();
          if (arg['videos'] != null && arg['currentIndex'] != null) {
            inlineVideos = arg['videos'] as List<dynamic>?;
            inlineIndex = (arg['currentIndex'] is int)
                ? arg['currentIndex'] as int
                : int.tryParse(arg['currentIndex'].toString()) ?? 0;
          }
        } else {
          vid = arg.toString();
        }
        final vidsForLog = inlineVideos != null
            ? 'provided inline videos(${inlineVideos.length})'
            : 'no inline videos';
        print(
          '[ShortVideoScreen] interpreted initial vid => $vid, $vidsForLog',
        );
        print('[ShortVideoScreen] interpreted initial vid => $vid');
        if (inlineVideos != null && inlineIndex != null) {
          try {
            // If caller provided a full videos list and index, use it to populate controller.videos for immediate navigation.
            final parsed = inlineVideos.map((e) {
              if (e is Map<String, dynamic>) return VideoModel.fromJson(e);
              return e as VideoModel;
            }).toList();
            controller.videos.assignAll(parsed);
            _initialPage = inlineIndex.clamp(0, parsed.length - 1);
            didJump = true;
            print(
              '[ShortVideoScreen] used inline videos, initialPage=$_initialPage',
            );
          } catch (e) {
            print('[ShortVideoScreen] failed to use inline videos: $e');
          }
        }

        if (vid != null) {
          // If videos are already loaded, jump immediately
          final existingIndex = controller.videos.indexWhere(
            (v) => v.id == vid,
          );
          if (existingIndex >= 0) {
            _initialPage = existingIndex;
            print('[ShortVideoScreen] found existingIndex => $existingIndex');
            didJump = true;
          }

          // find index after videos load; use GetX `ever` so we reliably
          // react when the RxList updates (works even if videos load later).
          if (!didJump) {
            ever(controller.videos, (list) {
              try {
                if (didJump) return;
                final items = (list as List); // GetX provides a non-null list
                final index = items.indexWhere((v) {
                  try {
                    final id = (v as dynamic).id ?? '';
                    return id == vid;
                  } catch (_) {
                    return false;
                  }
                });
                if (index >= 0) {
                  didJump = true;
                  print('[ShortVideoScreen] index found after load => $index');
                  if (mounted) {
                    // If page controller already has clients, jump directly.
                    if (_pageCtrl.hasClients) {
                      _pageCtrl.jumpToPage(index);
                    } else {
                      // Otherwise update initial page so created controller starts there
                      setState(() {
                        _initialPage = index;
                      });
                    }
                  }
                }
              } catch (e) {
                print('[ShortVideoScreen] ever listener error: $e');
              }
            });
          }
        }
      } catch (e) {
        print('[ShortVideoScreen] error reading initial arg: $e');
      }
    }
    _pageCtrl = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  final ApiService _apiService = ApiService();
  String _fullUrl(String path) => _apiService.fullMediaUrl(path);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.videos.isEmpty) {
          return const Center(
            child: Text(
              "No videos found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return PageView.builder(
          controller: _pageCtrl,
          scrollDirection: Axis.vertical,
          itemCount: controller.videos.length,
          onPageChanged: controller.setCurrentPage,
          itemBuilder: (context, index) {
            final video = controller.videos[index];
            final videoUrl = _fullUrl(video.videoUrl);
            print("[ShortVideoScreen] Playing videoUrl: $videoUrl");

            return Stack(
              fit: StackFit.expand,
              children: [
                // Video Player
                VideoPlayerWidget(
                  videoUrl: videoUrl,
                  onDoubleTap: () async {
                    await controller.toggleLike(index);
                  },
                ),

                // Bottom left info
                Positioned(
                  left: 10,
                  bottom: 40,
                  right: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              final avatarUrl = _fullUrl(video.uploaderImage);
                              final hasAvatar = avatarUrl.isNotEmpty;
                              return CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: hasAvatar
                                    ? NetworkImage(avatarUrl) as ImageProvider
                                    : null,
                                child: hasAvatar
                                    ? null
                                    : const Icon(
                                        Icons.person,
                                        color: Colors.black,
                                      ),
                              );
                            },
                          ),
                          SizedBox(width: 8),
                          Text(
                            (video.uploaderName.isNotEmpty)
                                ? video.uploaderName
                                : 'Unknown user',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSizer().height1,
                        width: AppSizer().width3,
                      ),
                      Text(
                        video.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizer().fontSize16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right action column
                Positioned(
                  right: 8,
                  bottom: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Like
                      Obx(() {
                        final isLiked = video.isLikedBy(
                          controller.currentUserId.value,
                        );
                        return GestureDetector(
                          onTap: () async => await controller.toggleLike(index),
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: isLiked ? Colors.red : Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${video.likes.length}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 20),

                      // Comment
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                CommentBottomSheet(videoIndex: index),
                          );
                        },
                        child: Column(
                          children: [
                            const Icon(
                              Icons.comment,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${video.comments.length}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Share
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => ShareVideoBottomSheet(
                              videoPathOrUrl: video.videoUrl,
                            ),
                          );
                        },
                        child: Column(
                          children: const [
                            Icon(Icons.share, color: Colors.white, size: 30),
                            SizedBox(height: 6),
                            Text(
                              "Share",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Add new video
                      GestureDetector(
                        onTap: () {
                          Get.to(() => PostVideoScreen());
                        },
                        child: Column(
                          children: const [
                            Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 34,
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Add",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top bar
                Positioned(
                  top: 40,
                  left: 12,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const SizedBox(width: 8),
                      Center(
                        child: const Text(
                          "Short Videos",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}
