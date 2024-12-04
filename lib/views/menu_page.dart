import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/constants/constants.dart';
import 'package:melodia/providers/watch_history_provider.dart';
import 'package:melodia/services/api_calls.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/about_me.dart';
import 'package:melodia/views/settings_page.dart';
import 'package:melodia/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  List<String> abi = [];
  void showUpdateDialog(String latestVersion) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    deviceInfo.androidInfo.then((androidInfo) {
      setState(() {
        abi = androidInfo.supportedAbis;
      });
    });

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Update Available',
          style: TextStyle(color: AppTheme.accentColor(ref)),
        ),
        content: Text(
            'Another latest stable version ($latestVersion) is available.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              String urlToHit = '';
              if (abi.contains('armeabi-v7a')) {

                urlToHit +=
                    'https://github.com/iamthetwodigiter/Melodia/releases/download/$latestVersion/Melodia-$latestVersion-armeabi-v7a.apk';
              } else if (abi.contains('arm64-v8a')) {
                urlToHit +=
                    'https://github.com/iamthetwodigiter/Melodia/releases/download/$latestVersion/Melodia-$latestVersion-arm64-v8a.apk';
              } else if (abi.contains('x86')) {
                urlToHit +=
                    'https://github.com/iamthetwodigiter/Melodia/releases/download/$latestVersion/Melodia-$latestVersion-x86_64.apk';
              } else {
                urlToHit +=
                    'https://github.com/iamthetwodigiter/Melodia/releases/download/$latestVersion/Melodia-$latestVersion-universal.apk';
              }
              launchUrl(Uri.parse(urlToHit));
            },
            child: Text(
              'Update',
              style: TextStyle(color: AppTheme.accentColor(ref)),
            ),
          ),
        ],
      ),
    );
  }

  void noUpdateDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'No Update Available',
          style: TextStyle(color: AppTheme.accentColor(ref)),
        ),
        content: const Text('Latest version is already installed.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showErrorDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text('Error fetching upadtes!!'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Okay', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> updateChecker() async {
    try {
      final latestVersion = await fetchUpdates();
      if (appVersion != latestVersion) {
        showUpdateDialog(latestVersion);
      } else {
        noUpdateDialog();
      }
    } catch (e) {
      showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Menu",
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
        child: SizedBox(
          child: ListView(
            children: [
              ListTile(
                //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                leading: Icon(Icons.settings, color: AppTheme.accentColor(ref)),
                title: const Text('Settings'),
                subtitle: const Text('Tune it to your preference'),
                titleTextStyle: TextStyle(
                  color: AppTheme.accentColor(ref),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
              ListTile(
                //  tileColor: AppTheme.accentColor(ref)!.withAlpha(50),
                leading: Icon(Icons.delete, color: AppTheme.accentColor(ref)),
                title: const Text('Clear History'),
                subtitle: const Text('Clear your streaming history'),
                titleTextStyle: TextStyle(
                  color: AppTheme.accentColor(ref),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                onTap: () {
                  history.clearHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                      customSnackBar('History has been cleared', ref));
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                iconColor: AppTheme.accentColor(ref),
                title: const Text("Help & Support"),
                titleTextStyle: TextStyle(
                  color: AppTheme.accentColor(ref),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: const Text(
                    "Join the support group to report bugs or request new features"),
                onTap: () {
                  launchUrl(Uri.parse('https://t.me/melodia_support_group'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.security_update),
                iconColor: AppTheme.accentColor(ref),
                title: const Text("Check for Updates"),
                titleTextStyle: TextStyle(
                  color: AppTheme.accentColor(ref),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: const Text(
                    "Try new features and enjoy bug-free experience with latest updates"),
                onTap: () {
                  updateChecker();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_rounded),
                iconColor: AppTheme.accentColor(ref),
                title: const Text("About Me"),
                titleTextStyle: TextStyle(
                  color: AppTheme.accentColor(ref),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: const Text(
                    "The nerd who spent sleepless nights working on the project"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutMe(),
                    ),
                  );
                },
              ),
              ListTile(
                // leading: const Icon(Icons.developer_mode),
                iconColor: AppTheme.accentColor(ref),
                title: const Text("Melodia $appVersion",
                    textAlign: TextAlign.center),
                titleTextStyle: TextStyle(
                  color: AppTheme.accentColor(ref),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                subtitle: const Text("Created with ❤️ by thetwodigiter",
                    textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
