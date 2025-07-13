import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
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

  // 영상 구간(초)
  final List<Map<String, double>> segments = [
    {'start': 0.00,   'end': 3.7},
    {'start': 3.7,    'end': 8.06},
    {'start': 8.06,   'end': 8.4},
    {'start': 9.8,    'end': 9.85},
    {'start': 11.15,  'end': 11.2},
    {'start': 12.38,  'end': 12.43},
    {'start': 13.73,  'end': 13.78},
    {'start': 15.35,  'end': 15.40},
    {'start': 16.35,  'end': 26.8},
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

  Color getOverlayColor() {
    // 17초 이후에만 색 변경, 아니면 기본색
    if (segments[currentSegment]['start']! >= 17.0) {
      return const Color(0xFFEEEEEE); // 예시, 원하는 HEX로 변경
    }
    return const Color(0xFFF4F4F7); // 처음부터 17초 전까지
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
                    final videoW = _controller.value.size.width;
                    final videoH = _controller.value.size.height;
                    final aspect = _controller.value.aspectRatio;

                    final showW = constraints.maxWidth;
                    final showH = showW / aspect;

                    // 상단/하단 오버레이 px 비율(이미지 1662px 기준)
                    const double topOverlayPx = 95;
                    const double bottomOverlayPx = 40;
                    const double baseHeight = 1662.0;
                    final double topOverlay = showH * (topOverlayPx / baseHeight);
                    final double bottomOverlay = showH * (bottomOverlayPx / baseHeight);

                    // 예시: 잔액 오버레이 위치/크기 (좌표는 직접 맞추면 완벽)
                    final double balanceLeft = showW * 54 / 390;     // 예시 390 기준
                    final double balanceTop = showH * 413 / 844;     // 예시 844 기준
                    final double balanceWidth = showW * 280 / 390;
                    final double balanceHeight = showH * 90 / 844;

                    return Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: aspect,
                          child: VideoPlayer(_controller),
                        ),
                        // 상단 오버레이(항상)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          height: topOverlay,
                          child: Container(color: getOverlayColor()),
                        ),
                        // 하단 오버레이(항상)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          height: bottomOverlay,
                          child: Container(color: getOverlayColor()),
                        ),
                        // 잔액 오버레이(항상 표시, 위치/크기 예시)
                        Positioned(
                          left: balanceLeft,
                          top: balanceTop,
                          width: balanceWidth,
                          height: balanceHeight,
                          child: Container(
                            color: getOverlayColor(),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Text(
                                "7,875,668,571원",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Pretendard", // 구글폰트 또는 NotoSansKR 등 유사체
                                ),
                              ),
                            ),
                          ),
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
