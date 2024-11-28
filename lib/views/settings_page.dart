import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/providers/settings_provider.dart';
import 'package:melodia/utils/colors.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final qualities = [48, 96, 160, 320];
    final youtubeQualities = [48, 128];

    void showAccentColorDialog() {
      List<Color> colors = [
        Colors.amber,
        Colors.blue,
        Colors.blueGrey,
        Colors.brown,
        Colors.cyan,
        Colors.deepOrange,
        Colors.deepPurple,
        Colors.green,
        // Colors.grey,
        Colors.indigo,
        Colors.lightBlue,
        Colors.lightGreen,
        Colors.lime,
        Colors.orange,
        Colors.pink,
        Colors.purple,
        Colors.red,
        Colors.teal,
        Colors.yellow,
      ];

      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: colors.length ~/ 3,
            itemBuilder: (context, index) {
              Color color1 = colors[3 * index];
              Color color2 = colors[3 * index + 1];
              Color color3 = colors[3 * index + 2];
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            notifier.updateAccentColor(color1);
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 75,
                          width: size.width / 3 - 20,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: color1,
                          ),
                        ),
                      ),
                      if (settings?.accentColor == color1)
                        const Positioned(
                          bottom: 15,
                          right: 15,
                          child: Icon(
                            Icons.done,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            notifier.updateAccentColor(color2);
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          height: 75,
                          width: size.width / 3 - 20,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: color2,
                          ),
                        ),
                      ),
                      if (settings?.accentColor == color2)
                        const Positioned(
                          bottom: 15,
                          right: 15,
                          child: Icon(
                            Icons.done,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            notifier.updateAccentColor(color3);
                            Navigator.pop(context);
                          });
                        },
                        child: Container(
                          height: 75,
                          width: size.width / 3 - 20,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: color3,
                          ),
                        ),
                      ),
                      if (settings?.accentColor == color3)
                        const Positioned(
                          bottom: 15,
                          right: 15,
                          child: Icon(
                            Icons.done,
                            size: 25,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
    }

    if (settings == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
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
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.color_lens),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("Accent Color"),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              subtitle: const Text('Set the app accent color to your choice'),
              onTap: () {
                showAccentColorDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("Download"),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              subtitle: const Text("Select Download Quality"),
              trailing: DropdownButton<int>(
                value: settings.downloadQuality,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: const Color.fromARGB(255, 39, 39, 39),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    notifier.updateDownloadQuality(newValue);
                  }
                },
                items: qualities.map((int quality) {
                  return DropdownMenuItem<int>(
                    value: quality,
                    child: Text('$quality kbps'),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("Streaming"),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              subtitle: const Text("Select Streaming Quality"),
              trailing: DropdownButton<int>(
                value: settings.streamingQuality,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: const Color.fromARGB(255, 39, 39, 39),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    notifier.updateStreamingQuality(newValue);
                  }
                },
                items: qualities.map((int quality) {
                  return DropdownMenuItem<int>(
                    value: quality,
                    child: Text('$quality kbps'),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("YouTube Download"),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              subtitle: const Text("Select YouTube Download Quality"),
              trailing: DropdownButton<int>(
                value: settings.ytDownloadQuality,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: const Color.fromARGB(255, 39, 39, 39),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    notifier.updateYTDownloadQuality(newValue);
                  }
                },
                items: youtubeQualities.map((int quality) {
                  return DropdownMenuItem<int>(
                    value: quality,
                    child: Text('$quality kbps'),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("YouTube Streaming"),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              subtitle: const Text("Select YouTube Streaming Quality"),
              trailing: DropdownButton<int>(
                value: settings.ytStreamingQuality,
                icon: const Icon(Icons.arrow_drop_down),
                dropdownColor: const Color.fromARGB(255, 39, 39, 39),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    notifier.updateYTStreamingQuality(newValue);
                  }
                },
                items: youtubeQualities.map((int quality) {
                  return DropdownMenuItem<int>(
                    value: quality,
                    child: Text('$quality kbps'),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shuffle),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("Keep Shuffle Mode On"),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              trailing: CupertinoSwitch(
                activeColor: AppTheme.accentColor(ref),
                value: settings.shuffleMode,
                onChanged: (value) {
                  notifier.updateShuffleMode(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              iconColor: AppTheme.accentColor(ref),
              title: const Text("Albums/Playlists Folders"),
              subtitle:
                  const Text('Download Albums/Playlists in separate folders'),
              titleTextStyle: TextStyle(
                color: AppTheme.accentColor(ref),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              trailing: CupertinoSwitch(
                activeColor: AppTheme.accentColor(ref),
                value: settings.separatePlaylistFolder,
                onChanged: (value) {
                  notifier.updateseparatePlaylistFolder(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
