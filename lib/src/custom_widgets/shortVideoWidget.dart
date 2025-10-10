import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool muted;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onPlayPause;
  final bool enableTapToToggle;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    this.muted = false,
    this.onDoubleTap,
    this.onPlayPause,
    this.enableTapToToggle = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showPlay = false;
  bool _initError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _initError = false;
      });
      _controller.setLooping(true);
      // respect muted setting
      _controller.setVolume(widget.muted ? 0.0 : 1.0);
      _controller.play();
    }).catchError((e) {
      print("[VideoPlayerWidget] init error: $e");
      if (mounted) {
        setState(() {
          _initError = true;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller.pause();
      try {
        _controller.dispose();
      } catch (_) {}
      _isInitialized = false;
      _initError = false;
      _controller = VideoPlayerController.network(widget.videoUrl);
      _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(widget.muted ? 0.0 : 1.0);
        _controller.play();
      }).catchError((e) {
        print('[VideoPlayerWidget] didUpdateWidget init error: $e');
        if (mounted) setState(() => _initError = true);
      });
    } else if (oldWidget.muted != widget.muted && _isInitialized) {
      // update volume if muted flag changed
      _controller.setVolume(widget.muted ? 0.0 : 1.0);
    }
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (_) {}
    super.dispose();
  }

  void togglePlayPause() {
    if (!_isInitialized) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showPlay = true);
    } else {
      _controller.play();
      setState(() => _showPlay = false);
    }
    widget.onPlayPause?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        print("[VideoPlayerWidget] double tap");
        widget.onDoubleTap?.call();
      },
      onTap: widget.enableTapToToggle ? togglePlayPause : null,
      child: _initError
          ? const Center(child: Icon(Icons.broken_image))
          : (_isInitialized
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    if (_showPlay)
                      const Center(
                        child: Icon(
                          Icons.play_arrow,
                          size: 80,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                )
              : const Center(child: CircularProgressIndicator())),
    );
  }
}
