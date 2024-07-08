import 'package:flutter/cupertino.dart';
import 'package:melodia/settings/widgets/color_buttons.dart';

class AccentColorModal extends StatelessWidget {
  const AccentColorModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      height: 450,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ColorCards(
                  color1: CupertinoColors.destructiveRed,
                  color2: CupertinoColors.destructiveRed.withAlpha(200),
                  color3: CupertinoColors.destructiveRed.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.activeBlue,
                  color2: CupertinoColors.activeBlue.withAlpha(200),
                  color3: CupertinoColors.activeBlue.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.activeGreen,
                  color2: CupertinoColors.activeGreen.withAlpha(200),
                  color3: CupertinoColors.activeGreen.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.activeOrange,
                  color2: CupertinoColors.activeOrange.withAlpha(200),
                  color3: CupertinoColors.activeOrange.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemBrown,
                  color2: CupertinoColors.systemBrown.withAlpha(200),
                  color3: CupertinoColors.systemBrown.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemCyan,
                  color2: CupertinoColors.systemCyan.withAlpha(200),
                  color3: CupertinoColors.systemCyan.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemIndigo,
                  color2: CupertinoColors.systemIndigo.withAlpha(200),
                  color3: CupertinoColors.systemIndigo.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemMint,
                  color2: CupertinoColors.systemMint.withAlpha(200),
                  color3: CupertinoColors.systemMint.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemPink,
                  color2: CupertinoColors.systemPink.withAlpha(200),
                  color3: CupertinoColors.systemPink.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemPurple,
                  color2: CupertinoColors.systemPurple.withAlpha(200),
                  color3: CupertinoColors.systemPurple.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemTeal,
                  color2: CupertinoColors.systemTeal.withAlpha(200),
                  color3: CupertinoColors.systemTeal.withAlpha(150),
                ),
                const SizedBox(height: 15),
                ColorCards(
                  color1: CupertinoColors.systemYellow,
                  color2: CupertinoColors.systemYellow.withAlpha(200),
                  color3: CupertinoColors.systemYellow.withAlpha(150),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
