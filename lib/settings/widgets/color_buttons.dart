import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/core/landing_screen.dart';

Box settings = Hive.box('settings');

class ColorCards extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() => _ColorCardsState();
}

class _ColorCardsState extends ConsumerState<ColorCards> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          onPressed: () {
            settings.put('accent_color', [
              widget.color1.alpha,
              widget.color1.red,
              widget.color1.green,
              widget.color1.blue
            ]);
            setState(() {});

            Navigator.of(context).pop();
          },
          color: widget.color1,
          child: const Text(''),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          onPressed: () {
            settings.put('accent_color', [
              widget.color2.alpha,
              widget.color2.red,
              widget.color2.green,
              widget.color2.blue
            ]);

            setState(() {});

            Navigator.of(context).pop();
          },
          color: widget.color2,
          child: const Text(''),
        ),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          onPressed: () {
            settings.put('accent_color', [
              widget.color3.alpha,
              widget.color3.red,
              widget.color3.green,
              widget.color3.blue
            ]);

            setState(() {});

            Navigator.of(context).pop();
          },
          color: widget.color3,
          child: const Text(''),
        ),
      ],
    );
  }
}
