import 'package:flutter/cupertino.dart';
import 'package:melodia/settings/view/accent_color_modal.dart';

class SetUpExtend extends StatefulWidget {
  const SetUpExtend({super.key});

  @override
  State<SetUpExtend> createState() => _SetUpExtendState();
}

class _SetUpExtendState extends State<SetUpExtend> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Setup Screen'),
      ),
      child: Center(
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Personalise the app\nJust the way you like',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: const Text(
                  'Choose accent color',
                  style: TextStyle(fontSize: 20, color: CupertinoColors.white),
                ),
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => const CupertinoPopupSurface(
                      child: AccentColorModal(),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
