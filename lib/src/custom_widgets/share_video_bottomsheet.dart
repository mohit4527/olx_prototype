import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/short_video_controller.dart';
import '../model/short_video_model/short_video_model.dart';
import '../services/apiServices/apiServices.dart';

class ShareVideoBottomSheet extends StatelessWidget {
  final String videoPathOrUrl; // can be full url or relative
  const ShareVideoBottomSheet({Key? key, required this.videoPathOrUrl})
    : super(key: key);

  String getFull(String path) {
    final fixed = path.replaceAll("\\", "/");
    if (fixed.startsWith("http")) return fixed;
    final base = "https://oldmarket.bhoomi.cloud/";
    final rel = fixed.startsWith("/") ? fixed.substring(1) : fixed;
    return "$base$rel";
  }

  @override
  Widget build(BuildContext context) {
    final shareUrl = getFull(videoPathOrUrl);
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
            "Share Video",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _item(
                FontAwesomeIcons.whatsapp,
                "WhatsApp",
                () => _launch(
                  "https://wa.me/?text=${Uri.encodeComponent(shareUrl)}",
                  shareUrl,
                ),
              ),
              _item(
                FontAwesomeIcons.facebook,
                "Facebook",
                () => _launch(
                  "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}",
                  shareUrl,
                ),
              ),
              _item(
                FontAwesomeIcons.telegram,
                "Telegram",
                () => _launch(
                  "https://t.me/share/url?url=${Uri.encodeComponent(shareUrl)}",
                  shareUrl,
                ),
              ),
              _item(
                FontAwesomeIcons.instagram,
                "Instagram",
                () => Share.share(shareUrl),
              ),
              _item(
                Icons.sms,
                "SMS",
                () => _launch(
                  "sms:?body=${Uri.encodeComponent(shareUrl)}",
                  shareUrl,
                ),
              ),
              _item(Icons.share, "Others", () => Share.share(shareUrl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, size: 36)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _launch(String url, String fallback) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(fallback);
    }
  }
}

// -------------------- Comment Bottom Sheet --------------------

class CommentBottomSheet extends StatefulWidget {
  final int videoIndex;

  CommentBottomSheet({super.key, required this.videoIndex});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController commentController = TextEditingController();
  final Map<String, String> _avatarCache =
      {}; // userId -> avatarUrl (empty = no avatar)
  final Set<String> _fetching = {};
  final Map<String, String> _nameCache = {}; // userId -> displayName
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadCachesFromPrefs();
  }

  Future<void> _loadCachesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;
      final nameJson = prefs.getString('profile_name_cache') ?? '{}';
      final avatarJson = prefs.getString('profile_avatar_cache') ?? '{}';
      try {
        final Map<String, dynamic> names =
            json.decode(nameJson) as Map<String, dynamic>;
        names.forEach((k, v) {
          if (v != null) _nameCache[k] = v.toString();
        });
      } catch (_) {}
      try {
        final Map<String, dynamic> avs =
            json.decode(avatarJson) as Map<String, dynamic>;
        avs.forEach((k, v) {
          if (v != null) _avatarCache[k] = v.toString();
        });
      } catch (_) {}
      if (mounted) setState(() {});
    } catch (_) {}
  }

  String _getFull(String path) {
    final fixed = path.replaceAll("\\", "/");
    if (fixed.startsWith("http")) return fixed;
    final base = "https://oldmarket.bhoomi.cloud/";
    final rel = fixed.startsWith("/") ? fixed.substring(1) : fixed;
    return "$base$rel";
  }

  Future<void> _ensureAvatarFor(String userId) async {
    if (userId.isEmpty) return;
    if (_avatarCache.containsKey(userId) || _fetching.contains(userId)) return;
    _fetching.add(userId);
    try {
      print(
        '[CommentBottomSheet] _ensureAvatarFor -> fetching profile for userId=$userId',
      );
      final profile = await ApiService.fetchUserProfile(userId);
      print(
        '[CommentBottomSheet] _ensureAvatarFor -> fetched profile for $userId: $profile',
      );
      final image = profile == null
          ? ''
          : (profile['profileImage'] ??
                    profile['profile_image'] ??
                    profile['image'] ??
                    profile['photo'] ??
                    '')
                .toString();
      final name = profile == null
          ? ''
          : (profile['name'] ??
                    profile['displayName'] ??
                    profile['username'] ??
                    '')
                .toString();

      _avatarCache[userId] = image;
      if (name.isNotEmpty) _nameCache[userId] = name;
      print(
        '[CommentBottomSheet] caches updated for $userId -> name=${_nameCache[userId]} image=${_avatarCache[userId]}',
      );

      // persist caches to SharedPreferences so resolved names/images survive app restarts
      try {
        final prefs = _prefs ?? await SharedPreferences.getInstance();
        _prefs = prefs;
        await prefs.setString('profile_name_cache', json.encode(_nameCache));
        await prefs.setString(
          'profile_avatar_cache',
          json.encode(_avatarCache),
        );
      } catch (_) {}

      // Also update the comment model in the controller so other users see the name/image
      try {
        final controller = Get.find<ShortVideoController>();
        final video = controller.videos[widget.videoIndex];
        final idx = video.comments.indexWhere((c) {
          if (c.userId != userId) return false;
          final name = c.userName.trim().toLowerCase();
          final nameUnresolved = name.isEmpty || name.contains('unknown');
          final imageUnresolved = c.userImage.trim().isEmpty;
          return imageUnresolved || nameUnresolved;
        });
        if (idx != -1) {
          final old = video.comments[idx];
          final updated = CommentModel(
            id: old.id,
            userId: old.userId,
            userName: (_nameCache[userId] ?? '').isNotEmpty
                ? _nameCache[userId]!
                : old.userName,
            userImage: (_avatarCache[userId] ?? '').isNotEmpty
                ? _avatarCache[userId]!
                : old.userImage,
            text: old.text,
          );
          video.comments[idx] = updated;
          controller.videos[widget.videoIndex] = video;
        }
      } catch (e) {
        // ignore if controller not found or update fails
      }
      print('[CommentBottomSheet] _ensureAvatarFor finished for $userId');
      if (mounted) setState(() {});
    } catch (_) {
      _avatarCache[userId] = '';
      print('[CommentBottomSheet] _ensureAvatarFor failed for $userId');
    } finally {
      _fetching.remove(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShortVideoController>();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          // Animated padding so the sheet content moves up when keyboard appears.
          // Add a small extra bottom inset to avoid tiny RenderFlex overflows
          // when the system keyboard / emoji panel animates in.
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(width: 50, height: 4, color: Colors.grey),
                const SizedBox(height: 12),

                // Comments list
                Expanded(
                  child: Obx(() {
                    final comments =
                        controller.videos[widget.videoIndex].comments;
                    print(
                      '[CommentBottomSheet] rendering comments for videoIndex=${widget.videoIndex}, count=${comments.length}',
                    );
                    for (var cc in comments) {
                      print(
                        '[CommentBottomSheet] comment debug -> id=${cc.id} userId=${cc.userId} userName=${cc.userName} userImage=${cc.userImage} text=${cc.text}',
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 140),
                      itemCount: comments.length,
                      itemBuilder: (_, i) {
                        final c = comments[i];

                        // Resolve display name: prefer fetched name cache if available
                        String displayName = c.userName;
                        if (c.userId.isNotEmpty &&
                            _nameCache.containsKey(c.userId) &&
                            (_nameCache[c.userId] ?? '').isNotEmpty) {
                          displayName = _nameCache[c.userId]!;
                        }

                        // If this comment belongs to the currently logged-in user,
                        // prefer local stored displayName/photo (loaded into _prefs)
                        final currentUserId = controller.currentUserId.value;
                        final isCurrentUser =
                            c.userId.isNotEmpty && c.userId == currentUserId;
                        if (isCurrentUser && _prefs != null) {
                          final localName =
                              _prefs!.getString('user_display_name') ?? '';
                          if (localName.isNotEmpty) displayName = localName;
                          // prefer local photo if available later when building avatar
                        }

                        // If still empty, show a friendly fallback so a name is always visible
                        if (displayName.trim().isEmpty) displayName = 'Unknown';

                        // Prefer avatar provided inside CommentModel (fast, immediate)
                        final providedImage = c.userImage.isNotEmpty
                            ? c.userImage
                            : null;
                        String? avatarUrl = providedImage;

                        // If no provided image, try cached fetch for the userId
                        if ((avatarUrl == null || avatarUrl.isEmpty) &&
                            c.userId.isNotEmpty) {
                          if (!_avatarCache.containsKey(c.userId)) {
                            _ensureAvatarFor(c.userId);
                          }
                          avatarUrl = _avatarCache[c.userId];
                        }

                        Widget avatar;
                        if (avatarUrl != null && avatarUrl.isNotEmpty) {
                          avatar = CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(_getFull(avatarUrl)),
                          );
                        } else {
                          // If this is NOT the current user and name is unresolved,
                          // show a person icon (as the user requested).
                          final nameEmpty =
                              displayName.trim().isEmpty ||
                              displayName.toLowerCase().contains('unknown');
                          if (!isCurrentUser && nameEmpty) {
                            avatar = const CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white24,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            );
                          } else {
                            // For current user (or resolved names), show initials placeholder
                            final parts = displayName.split(' ');
                            String initials = '';
                            if (parts.isNotEmpty && parts[0].isNotEmpty)
                              initials += parts[0][0];
                            if (parts.length > 1 && parts[1].isNotEmpty)
                              initials += parts[1][0];
                            initials = initials.toUpperCase();
                            avatar = CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white24,
                              child: Text(
                                initials.isNotEmpty ? initials : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }
                        }

                        // If the comment lacks visible author info, allow tap-to-resolve
                        final needsResolve =
                            (displayName.trim().isEmpty ||
                                displayName.toLowerCase().contains(
                                  'unknown',
                                )) &&
                            (c.userImage.trim().isEmpty);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: InkWell(
                            onTap: needsResolve
                                ? () async {
                                    // optimistic feedback
                                    try {
                                      print(
                                        '[CommentBottomSheet] tap-to-resolve comment id=${c.id}',
                                      );
                                      final author =
                                          await ApiService.fetchCommentAuthor(
                                            c.id,
                                          );
                                      print(
                                        '[CommentBottomSheet] tap-to-resolve result for ${c.id} -> $author',
                                      );
                                      if (author != null) {
                                        final resolvedName =
                                            (author['name'] ??
                                                    author['displayName'] ??
                                                    author['username'] ??
                                                    '')
                                                .toString();
                                        final resolvedImage =
                                            (author['profileImage'] ??
                                                    author['profile_image'] ??
                                                    author['image'] ??
                                                    author['photo'] ??
                                                    '')
                                                .toString();

                                        // save to caches
                                        if (resolvedName.isNotEmpty)
                                          _nameCache[author['_id']
                                                      ?.toString() ??
                                                  c.userId] =
                                              resolvedName;
                                        if (resolvedImage.isNotEmpty)
                                          _avatarCache[author['_id']
                                                      ?.toString() ??
                                                  c.userId] =
                                              resolvedImage;

                                        // persist
                                        try {
                                          final prefs =
                                              _prefs ??
                                              await SharedPreferences.getInstance();
                                          _prefs = prefs;
                                          await prefs.setString(
                                            'profile_name_cache',
                                            json.encode(_nameCache),
                                          );
                                          await prefs.setString(
                                            'profile_avatar_cache',
                                            json.encode(_avatarCache),
                                          );
                                        } catch (_) {}

                                        // update controller model where possible
                                        try {
                                          final controller =
                                              Get.find<ShortVideoController>();
                                          final video = controller
                                              .videos[widget.videoIndex];
                                          for (
                                            int j = 0;
                                            j < video.comments.length;
                                            j++
                                          ) {
                                            final old = video.comments[j];
                                            if (old.id == c.id) {
                                              final updated = CommentModel(
                                                id: old.id,
                                                userId: old.userId.isNotEmpty
                                                    ? old.userId
                                                    : (author['_id']
                                                              ?.toString() ??
                                                          ''),
                                                userName:
                                                    resolvedName.isNotEmpty
                                                    ? resolvedName
                                                    : old.userName,
                                                userImage:
                                                    resolvedImage.isNotEmpty
                                                    ? resolvedImage
                                                    : old.userImage,
                                                text: old.text,
                                              );
                                              video.comments[j] = updated;
                                              controller.videos[widget
                                                      .videoIndex] =
                                                  video;
                                              break;
                                            }
                                          }
                                        } catch (e) {
                                          print(
                                            '[CommentBottomSheet] failed to update controller after resolve: $e',
                                          );
                                        }

                                        if (mounted) setState(() {});
                                      } else {
                                        Get.snackbar(
                                          'Info',
                                          'Author not found',
                                        );
                                      }
                                    } catch (e) {
                                      print(
                                        '[CommentBottomSheet] tap-to-resolve error: $e',
                                      );
                                    }
                                  }
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                avatar,
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.text,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white12,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            final text = commentController.text.trim();
                            if (text.isNotEmpty) {
                              controller.postComment(
                                widget.videoIndex,
                                text,
                              ); // ✅ fixed method
                              commentController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
