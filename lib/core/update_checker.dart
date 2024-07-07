import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:melodia/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateChecker {
  Future<String?> fetchLatestRelease() async {
    const url =
        'https://api.github.com/repos/iamthetwodigiter/melodia/releases/latest';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['tag_name'];
    } else {
      throw Exception('Failed to fetch latest release');
    }
  }

  Future<void> checkForUpdates(BuildContext context) async {
    try {
      final latestVersion = await fetchLatestRelease();
      const currentVersion = Constants.appVersion;

      if (latestVersion != null && latestVersion != currentVersion) {
        _showUpdateDialog(context, latestVersion);
      } else {
        _showNoUpdateDialog(context);
      }
    } catch (e) {
      _showErrorDialog(context, e.toString());
    }
  }

  void _showUpdateDialog(BuildContext context, String latestVersion) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Update Available'),
        content: Text('A new version ($latestVersion) is available.'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('https://melodiahub.netlify.app/#download'));
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showNoUpdateDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('No Update Available'),
        content: const Text('Your app is up-to-date.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: const Text('Error fetching upadtes!!'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
