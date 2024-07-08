import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
        Stack(
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
            (settings.get('accent_color').first.toString() ==
                        widget.color1.alpha.toString() &&
                    settings.get('accent_color')[1].toString() ==
                        widget.color1.red.toString() &&
                    settings.get('accent_color')[2].toString() ==
                        widget.color1.green.toString() &&
                    settings.get('accent_color')[3].toString() ==
                        widget.color1.blue.toString())
                ? const Icon(
                    Icons.done_rounded,
                    color: CupertinoColors.white,
                    size: 30,
                  )
                : const Icon(
                    Icons.done_rounded,
                    size: 0,
                  )
          ],
        ),
        Stack(
          children: [
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
            (settings.get('accent_color').first.toString() ==
                        widget.color2.alpha.toString() &&
                    settings.get('accent_color')[1].toString() ==
                        widget.color2.red.toString() &&
                    settings.get('accent_color')[2].toString() ==
                        widget.color2.green.toString() &&
                    settings.get('accent_color')[3].toString() ==
                        widget.color2.blue.toString())
                ? const Icon(
                    Icons.done_rounded,
                    color: CupertinoColors.white,
                    size: 30,
                  )
                : const Icon(
                    Icons.done_rounded,
                    size: 0,
                  )
          ],
        ),
        Stack(
          children: [
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
            (settings.get('accent_color').first.toString() ==
                        widget.color3.alpha.toString() &&
                    settings.get('accent_color')[1].toString() ==
                        widget.color3.red.toString() &&
                    settings.get('accent_color')[2].toString() ==
                        widget.color3.green.toString() &&
                    settings.get('accent_color')[3].toString() ==
                        widget.color3.blue.toString())
                ? const Icon(
                    Icons.done_rounded,
                    color: CupertinoColors.white,
                    size: 30,
                  )
                : const Icon(
                    Icons.done_rounded,
                    size: 0,
                  )
          ],
        ),
      ],
    );
  }
}
