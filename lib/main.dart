import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '우리WON뱅킹',
      debugShowCheckedModeBanner: false,
      home: const VideoSequencePage(),
    );
  }
}

class VideoSequencePage extends StatefulWidget {
  const VideoSequencePage({super.key});

  @override
  State<VideoSequencePage> createState() => _VideoSequencePageState();
}

class _VideoSequencePageState extends State<VideoSequencePage> {
  final List<String> videoList = List.generate(
    9,
    (i) => 'assets/videos/video${i + 1}.MOV',
  );
  late VideoPlayerController _controller;
  int currentIndex = 0;
  bool _isTransitioning = false;
  double _opacity = 1.0;

  // 실제 영상 해상도
  final int videoWidth = 1170;     // 아이폰12 Pro 기준
  final int videoHeight = 2532;
  final int cropTop = 60;          // 위 60px
  final int cropBottom = 30;       // 아래 30px

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
      await Future.delayed(const Duration(milliseconds: 220));
      await _controller.pause();
      await _controller.dispose();
      currentIndex++;
      await _initVideo(videoList[currentIndex]);
      setState(() {
        _opacity = 1.0;
      });
      await Future.delayed(const Duration(milliseconds: 180));
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

    // Crop 효과 (위 60px, 아래 30px)
    final double heightFactor =
        (videoHeight - cropTop - cropBottom) / videoHeight;

    return Center(
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: heightFactor,
          child: Padding(
            padding: EdgeInsets.only(top: cropTop.toDouble()),
            child: SizedBox(
              width: videoWidth.toDouble(),
              height: (videoHeight - cropTop - cropBottom).toDouble(),
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _nextVideo,
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(milliseconds: 180),
            child: _croppedVideo(),
          ),
        ),
      ),
    );
  }
}
