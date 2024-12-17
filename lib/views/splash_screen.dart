import 'package:flutter/material.dart';
import 'package:melodia/views/landing_page.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/splash/splash.mp4',
      videoPlayerOptions: VideoPlayerOptions(),
    );

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
      _controller.setLooping(false);

      _controller.addListener(() {
        if (_controller.value.position == _controller.value.duration) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LandingPage(),
            ),
          );
        }
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
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : const SizedBox(),
        ),
      ),
    );
  }
}
