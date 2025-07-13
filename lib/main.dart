import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '우리WON뱅킹',
        home: const VideoCropCustomSides(),
      );
}

class VideoCropCustomSides extends StatefulWidget {
  const VideoCropCustomSides({super.key});

  @override
  State<VideoCropCustomSides> createState() => _VideoCropCustomSidesState();
}

class _VideoCropCustomSidesState extends State<VideoCropCustomSides> {
  final int videoWidth = 1170;
  final int videoHeight = 2532;
  final int cropTop = 95;
  final int cropBottom = 40;

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

      // 다음 영상 미리 준비
      _nextController = VideoPlayerController.asset(videoList[nextIndex]);
      await _nextController!.initialize();
      _nextController!.play();
      _nextController!.setLooping(false);

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

  // video9 → 상하단 #F5F6FA, video2 하단 #F5F3F6, 나머지 하얀색
  Color getTopColor() {
    if (currentIndex == 8) {
      // video9
      return const Color(0xFFF5F6FA);
    }
    return Colors.white;
  }

  Color getBottomColor() {
    if (currentIndex == 8) {
      // video9
      return const Color(0xFFF5F6FA);
    } else if (currentIndex == 1) {
      // video2 (인덱스 1)
      return const Color(0xFFF5F3F6);
    }
    return Colors.white;
  }

  Widget _croppedVideo(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final int visibleHeight = videoHeight - cropTop - cropBottom;
    final double croppedAspect = videoWidth / visibleHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        final double widgetAspect = maxWidth / maxHeight;
        double viewWidth, viewHeight;
        if (widgetAspect > croppedAspect) {
          viewHeight = maxHeight;
          viewWidth = viewHeight * croppedAspect;
        } else {
          viewWidth = maxWidth;
          viewHeight = viewWidth / croppedAspect;
        }
        return Stack(
          children: [
            // 상단 배경
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: cropTop * viewHeight / visibleHeight,
              child: Container(color: getTopColor()),
            ),
            // 하단 배경
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: cropBottom * viewHeight / visibleHeight,
              child: Container(color: getBottomColor()),
            ),
            // crop된 비디오
            Positioned(
              top: cropTop * viewHeight / visibleHeight,
              left: (maxWidth - viewWidth) / 2,
              width: viewWidth,
              height: viewHeight,
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: viewWidth,
                  maxHeight: viewHeight + cropTop + cropBottom,
                  child: Stack(
                    children: [
                      Positioned(
                        top: -cropTop * viewHeight / visibleHeight,
                        left: 0,
                        child: SizedBox(
                          width: viewWidth,
                          height: viewHeight + cropTop + cropBottom,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _nextVideo,
        child: _croppedVideo(context),
      ),
    );
  }
}
