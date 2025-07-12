import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '우리WON뱅킹',
        home: const VideoCropFullSequence(),
      );
}

class VideoCropFullSequence extends StatefulWidget {
  const VideoCropFullSequence({super.key});

  @override
  State<VideoCropFullSequence> createState() => _VideoCropFullSequenceState();
}

class _VideoCropFullSequenceState extends State<VideoCropFullSequence> {
  final List<String> videoList = List.generate(
    9,
    (i) => 'assets/videos/video${i + 1}.MOV',
  );

  // 실제 영상 해상도(아이폰 12 Pro 기준)
  final int videoWidth = 1170;
  final int videoHeight = 2532;
  final int cropTop = 90;    // 상단 90px
  final int cropBottom = 20; // 하단 20px

  late VideoPlayerController _controller;
  int currentIndex = 0;
  bool _isTransitioning = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _initVideo(videoList[currentIndex]);
  }

  Future<void> _initVideo(String path) async {
    _controller = VideoPlayerController.asset(path);
    try {
      await _controller.initialize();
      setState(() {});
      _controller.play();
      _controller.setLooping(false);
    } catch (e) {
      setState(() {});
    }
  }

  Future<void> _nextVideo() async {
    if (currentIndex < videoList.length - 1 && !_isTransitioning) {
      _isTransitioning = true;
      setState(() {
        _opacity = 0.0;
      });
      await Future.delayed(const Duration(milliseconds: 180));
      await _controller.pause();
      await _controller.dispose();
      currentIndex++;
      await _initVideo(videoList[currentIndex]);
      setState(() {
        _opacity = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 120));
      _isTransitioning = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _croppedVideo() {
    if (_controller.value.hasError) {
      return Center(
        child: Text(
          '에러: ${_controller.value.errorDescription}',
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final int visibleHeight = videoHeight - cropTop - cropBottom;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: videoWidth.toDouble(),
          height: visibleHeight.toDouble(),
          child: Stack(
            children: [
              Positioned(
                top: -cropTop.toDouble(),
                left: 0,
                child: SizedBox(
                  width: videoWidth.toDouble(),
                  height: videoHeight.toDouble(),
                  child: VideoPlayer(_controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _nextVideo,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 120),
          child: _croppedVideo(),
        ),
      ),
    );
  }
}
