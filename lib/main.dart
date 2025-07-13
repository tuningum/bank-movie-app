import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '우리WON뱅킹',
        home: const VideoSegmentPlayer(),
      );
}

class VideoSegmentPlayer extends StatefulWidget {
  const VideoSegmentPlayer({super.key});

  @override
  State<VideoSegmentPlayer> createState() => _VideoSegmentPlayerState();
}

class _VideoSegmentPlayerState extends State<VideoSegmentPlayer> {
  final String videoPath = 'assets/videos/all.mov';

  // 보여줄 구간 정보(초)
  final List<Map<String, double>> segments = [
    {'start': 0.00,  'end': 7.16},
    {'start': 7.16,  'end': 9.19},
    {'start': 9.24,  'end': 10.03},
    {'start': 11.04, 'end': 11.09},
    {'start': 12.10, 'end': 12.15},
    {'start': 13.21, 'end': 13.25},
    {'start': 15.10, 'end': 15.15},
    {'start': 16.07, 'end': 26.22},
  ];

  late VideoPlayerController _controller;
  int currentSegment = 0;
  bool isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() => isReady = true);
        _playCurrentSegment();
      });
    _controller.addListener(_onPositionUpdate);
  }

  void _onPositionUpdate() {
    if (!isReady) return;
    final now = _controller.value.position.inMilliseconds / 1000.0;
    final end = segments[currentSegment]['end']!;
    // 구간이 끝나면 자동 pause
    if (now >= end) {
      _controller.pause();
    }
  }

  Future<void> _playCurrentSegment() async {
    final start = segments[currentSegment]['start']!;
    await _controller.seekTo(Duration(milliseconds: (start * 1000).round()));
    await _controller.play();
  }

  Future<void> _nextSegment() async {
    if (currentSegment < segments.length - 1) {
      setState(() => currentSegment++);
      await _playCurrentSegment();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPositionUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextSegment,
        child: Center(
          child: isReady
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
