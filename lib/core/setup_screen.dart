import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/core/landing_screen.dart';
import 'package:melodia/core/setup_extended.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  double _iconPosition = 0;
  double _textOpacity = 1;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CupertinoColors.black.withAlpha(100),
              CupertinoColors.systemBlue.withAlpha(100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 250,
                  ),
                  const Text(
                    'Melodia',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Column(
              children: [
                Text(
                  'Immerse yourself in the world of music 🎧',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              height: 75,
              width: double.infinity,
              decoration: BoxDecoration(
                color:darkMode ? CupertinoColors.darkBackgroundGray : CupertinoColors.lightBackgroundGray,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _iconPosition += details.delta.dx;
                        _textOpacity =
                            (1 - (_iconPosition / 275)).clamp(0.0, 1.0);
                      });
                      if (_iconPosition >= 275) {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const LandingScreen()),
                        );
                        Hive.box('settings').put('setup', false);
                        
                      }
                    },
                    child: Container(
                        transform:
                            Matrix4.translationValues(_iconPosition, 0, 0),
                        padding: const EdgeInsets.all(17.5),
                        decoration: const BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/chevron.png',
                          height: 20,
                          color: CupertinoColors.white,
                        )),
                  ),
                  const SizedBox(width: 30),
                  Opacity(
                    opacity: _textOpacity,
                    child: const Text('Swipe to Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
