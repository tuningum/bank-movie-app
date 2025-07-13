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
    {'start': 0.00,   'end': 3.70},
    {'start': 3.70,   'end': 8.00},
    {'start': 8.06,   'end': 8.40},
    {'start': 9.80,   'end': 9.85},
    {'start': 11.15,  'end': 11.20},
    {'start': 12.38,  'end': 12.43},
    {'start': 13.73,  'end': 13.78},
    {'start': 15.35,  'end': 15.40},
    {'start': 16.35,  'end': 26.80},
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
    await Future.delayed(const Duration(milliseconds: 20));
    await _controller.play();
  }

  Future<void> _nextSegment() async {
    if (currentSegment < segments.length - 1) {
      setState(() => currentSegment++);
      await _playCurrentSegment();
    }
  }

  // 구간별 상하단 색상 반환
  Color getTopOverlayColor() {
    final start = segments[currentSegment]['start']!;
    if (start >= 16.35 && start < 17.0) {
      return const Color(0xFFF5F3F6); // 회색 (특수)
    }
    return Colors.white; // 기본 흰색
  }

  Color getBottomOverlayColor() {
    final start = segments[currentSegment]['start']!;
    if (start >= 17.0) {
      return const Color(0xFFF5F3F6); // 17초 이후 회색
    }
    if (start >= 16.35 && start < 17.0) {
      return const Color(0xFFF5F3F6); // 회색 (특수)
    }
    return Colors.white; // 기본 흰색
  }

  @override
  void dispose() {
    _controller.removeListener(_onPositionUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 캡처 기준(아이폰12pro 등)
    const double baseHeight = 844.0;
    const double topOverlayPx = 95;
    const double bottomOverlayPx = 40;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextSegment,
        child: Center(
          child: isReady
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final double showH = constraints.maxHeight;

                    final double topOverlay = showH * (topOverlayPx / baseHeight);
                    final double bottomOverlay = showH * (bottomOverlayPx / baseHeight);

                    return Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        // 상단 오버레이
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: topOverlay,
                          child: Container(color: getTopOverlayColor()),
                        ),
                        // 하단 오버레이
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: bottomOverlay,
                          child: Container(color: getBottomOverlayColor()),
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
