import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(TouchScenarioApp());

class TouchScenarioApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScenarioScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ScenarioScreen extends StatefulWidget {
  @override
  State<ScenarioScreen> createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  int currentStep = 0;
  VideoPlayerController? _videoController;
  bool _isVideoReady = false;

  // 시나리오별 타입/파일명 정의
  final List<Map<String, String>> steps = [
    {'type': 'video', 'file': 'assets/video1.mov'},
    {'type': 'video', 'file': 'assets/video2.mov'},
    {'type': 'image', 'file': 'assets/image1.png'},
    {'type': 'image', 'file': 'assets/image2.png'},
    {'type': 'image', 'file': 'assets/image3.png'},
    {'type': 'image', 'file': 'assets/image4.png'},
    {'type': 'image', 'file': 'assets/image5.png'},
    {'type': 'image', 'file': 'assets/image6.png'},
    {'type': 'video', 'file': 'assets/video3.mov'},
    {'type': 'image', 'file': 'assets/image7.png'},
  ];

  @override
  void initState() {
    super.initState();
    _prepareCurrentStep();
  }

  void _prepareCurrentStep() async {
    if (_videoController != null) {
      await _videoController?.pause();
      await _videoController?.dispose();
      _videoController = null;
    }
    setState(() {
      _isVideoReady = false;
    });

    if (steps[currentStep]['type'] == 'video') {
      _videoController = VideoPlayerController.asset(steps[currentStep]['file']!)
        ..initialize().then((_) {
          setState(() {
            _isVideoReady = true;
          });
          _videoController?.play();
          // 영상3에서만 자동 전환
          if (currentStep == 8) {
            _videoController?.addListener(() {
              if (_videoController!.value.position >= _videoController!.value.duration) {
                if (mounted && currentStep == 8) {
                  setState(() {
                    currentStep++;
                  });
                  _prepareCurrentStep();
                }
              }
            });
          }
        });
    }
  }

  void _onTap() {
    // 영상3(9번째)만 자동 전환, 나머지는 터치로 다음 단계
    if (currentStep == 8) return;
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
      _prepareCurrentStep();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        body: step['type'] == 'video'
            ? (_isVideoReady
                ? Center(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  )
                : Center(child: CircularProgressIndicator()))
            : Image.asset(
                step['file']!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }
}
