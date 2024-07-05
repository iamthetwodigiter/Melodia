import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/provider/dark_mode_provider.dart';
import 'package:melodia/settings/view/accent_color_modal.dart';

class ThemeSettings extends ConsumerStatefulWidget {
  const ThemeSettings({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThemeSettingsState();
}

Box settings = Hive.box('settings');

class _ThemeSettingsState extends ConsumerState<ThemeSettings> {
  @override
  Widget build(BuildContext context) {
    ref.watch(darkModeProvider);
    bool darkMode = settings.get('darkMode');
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          previousPageTitle: 'Settings',
          middle: Text(
            'Theme',
            style: TextStyle(
                color: darkMode
                    ? CupertinoColors.white
                    : AppPallete().accentColor),
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                  child: CupertinoListSection(
                topMargin: 0,
                backgroundColor: darkMode
                    ? AppPallete.scaffoldDarkBackground
                    : AppPallete.scaffoldBackgroundColor,
                children: [
                  CupertinoListTile(
                    backgroundColor: darkMode
                        ? AppPallete.scaffoldDarkBackground
                        : AppPallete.scaffoldBackgroundColor,
                    padding: const EdgeInsets.all(15),
                    leading: Icon(
                      CupertinoIcons.moon_circle_fill,
                      color: AppPallete().accentColor,
                      size: 20,
                    ),
                    title: Text(
                      'Dark Theme',
                      style: TextStyle(color: AppPallete().accentColor),
                    ),
                    trailing: CupertinoSwitch(
                      value: darkMode,
                      activeColor: AppPallete().accentColor,
                      onChanged: (bool value) {
                        ref
                            .watch(darkModeProvider.notifier)
                            .setDarkMode(!darkMode);
                        settings.put('darkMode', !darkMode);
                        setState(() {
                          value = !value;
                        });
                      },
                    ),
                  ),
                  CupertinoListTile(
                      backgroundColor: darkMode
                          ? AppPallete.scaffoldDarkBackground
                          : AppPallete.scaffoldBackgroundColor,
                      onTap: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext builder) {
                              return const CupertinoPopupSurface(
                                child: AccentColorModal(),
                              );
                            });
                      },
                      padding: const EdgeInsets.all(15),
                      leading: Icon(
                        Icons.color_lens,
                        color: AppPallete().accentColor,
                        size: 20,
                      ),
                      title: Text(
                        'Accent Color',
                        style: TextStyle(color: AppPallete().accentColor),
                      ),
                      subtitle: Text(
                        'Please restart app after changing color',
                        style: TextStyle(
                            color: darkMode
                                ? AppPallete.subtitleDarkTextColor
                                : AppPallete().subtitleTextColor),
                      ),
                      trailing: const CupertinoListTileChevron()),
                ],
              )),
            ],
          ),
        ));
  }
}
