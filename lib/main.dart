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

  // 영상 해상도 (아이폰 12 Pro 예시)
  final int videoWidth = 1170;
  final int videoHeight = 2532;
  final int cropTop = 92;    // 상단 92px
  final int cropBottom = 33; // 하단 33px

  late VideoPlayerController _controller;
  late VideoPlayerController? _nextController; // 다음 영상 컨트롤러 (전환 부드럽게)
  int currentIndex = 0;
  bool _isTransitioning = false;
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    _nextController = null;
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

  // 다음 영상 미리 준비, 준비되면 부드럽게 전환
  Future<void> _nextVideo() async {
    if (currentIndex < videoList.length - 1 && !_isTransitioning) {
      _isTransitioning = true;

      // 다음 영상 미리 초기화
      final nextIndex = currentIndex + 1;
      _nextController = VideoPlayerController.asset(videoList[nextIndex]);
      try {
        await _nextController!.initialize();
        _nextController!.play();
        _nextController!.setLooping(false);

        // 전환 애니메이션 (투명도 사용, 하지만 이전 화면은 그대로!)
        setState(() {
          _opacity = 0.0;
        });
        await Future.delayed(const Duration(milliseconds: 80));
        await _controller.pause();
        await _controller.dispose();
        _controller = _nextController!;
        currentIndex = nextIndex;
        _nextController = null;
        setState(() {
          _opacity = 1.0;
        });
        await Future.delayed(const Duration(milliseconds: 80));
      } catch (e) {
        // 에러시 무시하고 복구
        setState(() {});
      }
      _isTransitioning = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nextController?.dispose();
    super.dispose();
  }

  Widget _croppedVideo(VideoPlayerController controller) {
    if (controller.value.hasError) {
      return Center(
        child: Text(
          '에러: ${controller.value.errorDescription}',
          style: const TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }
    if (!controller.value.isInitialized) {
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
                  child: VideoPlayer(controller),
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
          duration: const Duration(milliseconds: 100),
          child: _croppedVideo(_controller),
        ),
      ),
    );
  }
}
