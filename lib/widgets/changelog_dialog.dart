import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/constants/constants.dart';
import 'package:melodia/utils/colors.dart';

class ChangelogDialog {
  static void show(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(maxHeight: context.size!.height / 2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 15,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Changelog',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.accentColor(ref),
                        ),
                      ),
                    ),
                  ],
                ),
                
                ...changelogs.map((versionData) {
                  final version = versionData.keys.first;
                  final updates = versionData[version]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          version,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...updates.map((update) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                "- $update",
                                style: const TextStyle(fontSize: 18),
                              ),
                            )),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
