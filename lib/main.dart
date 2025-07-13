import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const VideoOverlayApp(),
      );
}

class VideoOverlayApp extends StatefulWidget {
  const VideoOverlayApp({super.key});
  @override
  State<VideoOverlayApp> createState() => _VideoOverlayAppState();
}

class _VideoOverlayAppState extends State<VideoOverlayApp> {
  late VideoPlayerController _controller;
  bool isReady = false;
  double currentSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/all.mov')
      ..initialize().then((_) {
        setState(() => isReady = true);
        _controller.play();
      });
    _controller.addListener(() {
      setState(() {
        currentSeconds = _controller.value.position.inMilliseconds / 1000.0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 상단/하단 오버레이 px 값 (이미지 기준)
    const double topOverlayPx = 95;
    const double bottomOverlayPx = 40;
    // 예시 이미지 기준 전체 height (1662px)
    const double baseHeight = 1662.0;
    // 오버레이 색상
    const overlayColor = Color(0xFFF4F4F7);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: isReady
            ? LayoutBuilder(
                builder: (context, constraints) {
                  final videoWidth = constraints.maxWidth;
                  final videoHeight = constraints.maxHeight;
                  final topOverlay = videoHeight * (topOverlayPx / baseHeight);
                  final bottomOverlay = videoHeight * (bottomOverlayPx / baseHeight);
                  return Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      // 17초 이후에만 오버레이 표시
                      if (currentSeconds >= 17.0) ...[
                        // 상단 오버레이
                        Positioned(
                          left: 0,
                          top: 0,
                          right: 0,
                          height: topOverlay,
                          child: Container(color: overlayColor),
                        ),
                        // 하단 오버레이
                        Positioned(
                          left: 0,
                          bottom: 0,
                          right: 0,
                          height: bottomOverlay,
                          child: Container(color: overlayColor),
                        ),
                      ]
                    ],
                  );
                },
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
