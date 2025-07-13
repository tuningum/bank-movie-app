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
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final double videoW = _controller.value.size.width;
                    final double videoH = _controller.value.size.height;
                    final double aspect = _controller.value.aspectRatio;

                    final double showW = constraints.maxWidth;
                    final double showH = showW / aspect;

                    // 오버레이 높이를 비율로 변환
                    final double topOverlay = showH * 40 / videoH;
                    final double bottomOverlay = showH * 30 / videoH;

                    return Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: aspect,
                          child: VideoPlayer(_controller),
                        ),
                        // 상단 오버레이(40px)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: topOverlay,
                          child: Container(color: Colors.white),
                        ),
                        // 하단 오버레이(30px)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: bottomOverlay,
                          child: Container(color: Colors.white),
                        ),
                      ],
                    );
                  },
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
