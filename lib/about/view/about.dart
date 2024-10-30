import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodia/constants/constants.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Settings',
        middle: Text(
          'About',
          style: TextStyle(
            color: darkMode ? CupertinoColors.white : AppPallete().accentColor,
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 200,
                        ),
                        Text(
                          'Melodia',
                          style: TextStyle(
                            fontSize: 30,
                            color: AppPallete().accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          Constants.appVersion,
                          style: TextStyle(
                            fontSize: 25,
                            color: AppPallete().accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 18,
                              color: AppPallete().accentColor,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Created with ',
                                children: [
                                  WidgetSpan(
                                    child: Icon(
                                      CupertinoIcons.heart_solid,
                                      color: CupertinoColors.destructiveRed,
                                    ),
                                  ),
                                  TextSpan(text: ' by'),
                                ],
                              ),
                              TextSpan(text: '\nthetwodigiter')
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          style: const ButtonStyle(
                            fixedSize: MaterialStatePropertyAll(Size(100, 20)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white),
                          ),
                          onPressed: () async {
                            try {
                              await launchUrl(
                                Uri.parse(
                                  'https://www.github.com/iamthetwodigiter',
                                ),
                              );
                            } catch (e) {
                              rethrow;
                            }
                          },
                          child: const Text(
                            'Github',
                            style: TextStyle(
                              color: CupertinoColors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextButton(
                          style: const ButtonStyle(
                            fixedSize: MaterialStatePropertyAll(Size(100, 20)),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.white),
                          ),
                          onPressed: () async {
                            try {
                              await launchUrl(
                                Uri.parse(
                                  'https://www.instagram.com/thetwodigiter',
                                ),
                              );
                            } catch (e) {
                              rethrow;
                            }
                          },
                          child: Text(
                            'Instagram',
                            style: TextStyle(
                              color: Colors.pink[600],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
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
