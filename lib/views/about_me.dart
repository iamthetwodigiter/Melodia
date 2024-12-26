import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutMe extends ConsumerStatefulWidget {
  const AboutMe({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutMeState();
}

class _AboutMeState extends ConsumerState<AboutMe> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About Me",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: SizedBox(
                  height: size.height * 0.35,
                  child: FlipCard(
                    rotateSide: RotateSide.left,
                    onTapFlipping: true,
                    axis: FlipAxis.vertical,
                    controller: FlipCardController(),
                    frontWidget: Image.asset(
                      'assets/dev.jpg',
                      fit: BoxFit.fitWidth,
                    ),
                    backWidget: Image.asset(
                      'assets/dev.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Hey there, it\'s me ',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'thetwodigiter\n',
                      style: TextStyle(
                        color: AppTheme.accentColor(ref),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  text: 'I am a passionate ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Flutter ',
                      style: TextStyle(
                        color: Colors.blueAccent,
                      ),
                    ),
                    TextSpan(text: 'and '),
                    TextSpan(
                      text: 'Python ',
                      style: TextStyle(
                        color: Colors.amber,
                      ),
                    ),
                    TextSpan(
                      text: 'Dev from ',
                    ),
                    TextSpan(
                      text: 'India ❤️',
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Column(
                spacing: 10,
                children: [
                  const Text(
                    'You can contribute to the project here',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  InkWell(
                    child: Image.asset(
                      'assets/social/github.png',
                      height: 50,
                      width: 50,
                      color: Colors.white,
                    ),
                    onTap: () {
                      launchUrl(
                        Uri.parse(
                            'https://github.com/iamthetwodigiter/Melodia'),
                      );
                    },
                  ),
                  const Text(
                    'And if you feel like, you can buy me a coffee',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 10)),
                        backgroundColor: WidgetStatePropertyAll(Colors.white)),
                    child: Image.asset(
                      'assets/social/google_pay.png',
                      height: 50,
                      width: 50,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                          const ClipboardData(text: 'itsmeprabhatjana@oksbi'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        customSnackBar(
                            'UPI ID has been copied to clipboard', ref),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
