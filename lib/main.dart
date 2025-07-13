import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '우리WON뱅킹',
        home: const VideoCropWhiteTop(),
      );
}

class VideoCropWhiteTop extends StatefulWidget {
  const VideoCropWhiteTop({super.key});

  @override
  State<VideoCropWhiteTop> createState() => _VideoCropWhiteTopState();
}

class _VideoCropWhiteTopState extends State<VideoCropWhiteTop> {
  final int videoWidth = 1170;
  final int videoHeight = 2532;
  final int cropTop = 95;    // 상단 95px crop+화이트
  final int cropBottom = 35; // 하단 35px crop만

  final List<String> videoList = List.generate(
    9,
    (i) => 'assets/videos/video${i + 1}.MOV',
  );

  late VideoPlayerController _controller;
  VideoPlayerController? _nextController;
  int currentIndex = 0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _initVideo(videoList[currentIndex]);
  }

  Future<void> _initVideo(String path) async {
    _controller = VideoPlayerController.asset(path);
    await _controller.initialize();
    setState(() {});
    _controller.play();
    _controller.setLooping(false);
  }

  Future<void> _nextVideo() async {
    if (currentIndex < videoList.length - 1 && !_isTransitioning) {
      _isTransitioning = true;
      final nextIndex = currentIndex + 1;
      // 다음 영상 미리 초기화
      _nextController = VideoPlayerController.asset(videoList[nextIndex]);
      await _nextController!.initialize();
      _nextController!.play();
      _nextController!.setLooping(false);

      // 이전 컨트롤러는 화면에 계속 보여줌
      await _controller.pause();
      await _controller.dispose();
      _controller = _nextController!;
      currentIndex = nextIndex;
      _nextController = null;
      setState(() {});
      _isTransitioning = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nextController?.dispose();
    super.dispose();
  }

  Widget _croppedVideo() {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final int visibleHeight = videoHeight - cropTop - cropBottom;
    final double croppedAspect = videoWidth / visibleHeight;

    return AspectRatio(
      aspectRatio: croppedAspect,
      child: Stack(
        children: [
          // 상단 패딩(화이트)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: cropTop.toDouble(),
            child: Container(color: Colors.white),
          ),
          // crop된 비디오
          Positioned(
            top: cropTop.toDouble(),
            left: 0,
            right: 0,
            height: visibleHeight.toDouble(),
            child: ClipRect(
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _nextVideo,
        child: Center(
          child: _croppedVideo(),
        ),
      ),
    );
  }
}
