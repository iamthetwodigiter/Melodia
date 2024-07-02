import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:melodia/core/color_pallete.dart';
import 'package:melodia/settings/view/accent_color_modal.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

Box settings = Hive.box('settings');

class _ThemeSettingsState extends State<ThemeSettings> {
  @override
  Widget build(BuildContext context) {
    String darkMode = settings.get('darkMode');
    bool switchValue = (darkMode == 'false') ? false : true;
    return CupertinoPageScaffold(
        child: CustomScrollView(
      slivers: [
         SliverToBoxAdapter(
          child: CupertinoNavigationBar(
            previousPageTitle: 'Settings',
            middle: Text('Theme', style: TextStyle(color: AppPallete().accentColor),),
          ),
        ),
        SliverFillRemaining(
            child: CupertinoListSection(
          children: [
            CupertinoListTile(
              padding: const EdgeInsets.all(15),
              leading: Icon(
                CupertinoIcons.moon_circle_fill,
                color: AppPallete().accentColor,
                size: 20,
              ),
              title: Text('Dark Theme', style: TextStyle(color: AppPallete().accentColor),),
              trailing: CupertinoSwitch(
                value: switchValue,
                activeColor: AppPallete().accentColor,
                onChanged: (bool value) {
                  settings.put(
                      'darkMode', darkMode == 'false' ? 'true' : 'false');
                  setState(() {
                    switchValue = !switchValue;
                  });
                },
              ),
            ),
            CupertinoListTile(
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
                title: Text('Accent Color', style: TextStyle(color: AppPallete().accentColor),),
                subtitle: const Text('Please reload after changing color'),
                trailing: const CupertinoListTileChevron()),
          ],
        )),
      ],
    ));
  }
}
