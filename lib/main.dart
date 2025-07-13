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

  // 요청하신 9개 구간(초)
  final List<Map<String, double>> segments = [
    {'start': 0.00,   'end': 3.70},
    {'start': 3.70,   'end': 8.06},
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
    await _controller.play();
  }

  Future<void> _nextSegment() async {
    if (currentSegment < segments.length - 1) {
      setState(() => currentSegment++);
      await _playCurrentSegment();
    }
  }

  // 하단 컬러: 17초(16.35) 이상 구간만 특수색, 나머지는 하얀색
  Color getBottomOverlayColor() {
    if (segments[currentSegment]['start']! >= 17.0) {
      return const Color(0xFFF5F3F6);
    }
    return Colors.white;
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

                    // 오버레이 높이(비율 변환)
                    final double topOverlay = showH * 95 / videoH;
                    final double bottomOverlay = showH * 40 / videoH;

                    return Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: aspect,
                          child: VideoPlayer(_controller),
                        ),
                        // 상단 오버레이(95px)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: topOverlay,
                          child: Container(color: Colors.white),
                        ),
                        // 하단 오버레이(40px)
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
