import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Sequence App',
      home: VideoSequencePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VideoSequencePage extends StatefulWidget {
  @override
  State<VideoSequencePage> createState() => _VideoSequencePageState();
}

class _VideoSequencePageState extends State<VideoSequencePage> {
  final List<String> videoPaths = [
    'assets/videos/video1.mov',
    'assets/videos/video2.mov',
    'assets/videos/video3.mov',
    'assets/videos/video4.mov',
    'assets/videos/video5.mov',
    'assets/videos/video6.mov',
    'assets/videos/video7.mov',
    'assets/videos/video8.mov',
    'assets/videos/video9.mp4',
  ];
  int currentIndex = 0;
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    _controller?.dispose();
    _controller = VideoPlayerController.asset(videoPaths[currentIndex]);
    await _controller!.initialize();
    setState(() {
      _isInitialized = true;
    });
    _controller!.play();
    _controller!.setLooping(false);
  }

  Future<void> _nextVideo() async {
    if (currentIndex < videoPaths.length - 1) {
      setState(() {
        _isInitialized = false;
        currentIndex++;
      });
      await _loadVideo();
    }
    // 마지막 영상이면 아무 동작 없음
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (_controller != null && _controller!.value.isInitialized) {
            await _controller!.pause();
            await _nextVideo();
          }
        },
        child: Center(
          child: _isInitialized && _controller != null
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
