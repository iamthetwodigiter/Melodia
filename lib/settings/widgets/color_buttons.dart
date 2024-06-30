import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';

Box settings = Hive.box('settings');
List<int> accentColor = settings.get('accent_color');

class ColorCards extends StatelessWidget {
  final Color color1;
  final Color color2;
  final Color color3;
  const ColorCards({
    super.key,
    required this.color1,
    required this.color2,
    required this.color3,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          onPressed: () {
            settings.put('accent_color',
                [color1.alpha, color1.red, color1.green, color1.blue]);
            Navigator.of(context).pop();
          },
          color: color1,
          child: const Text(''),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          onPressed: () {
            settings.put('accent_color',
                [color2.alpha, color2.red, color2.green, color2.blue]);
            Navigator.of(context).pop();
          },
          color: color2,
          child: const Text(''),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          onPressed: () {
            settings.put('accent_color',
                [color3.alpha, color3.red, color3.green, color3.blue]);
            Navigator.of(context).pop();
          },
          color: color3,
          child: const Text(''),
        ),
      ],
    );
  }
}
