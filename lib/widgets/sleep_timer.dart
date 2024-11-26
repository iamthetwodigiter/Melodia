import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/utils/colors.dart';

class SleepTimerDialog extends ConsumerStatefulWidget {
  final VoidCallback stopMusic;
  final Duration? remainingDuration;
  final ValueChanged<Duration> onStartTimer;
  final VoidCallback onCancelTimer;

  const SleepTimerDialog({
    super.key,
    required this.stopMusic,
    this.remainingDuration,
    required this.onStartTimer,
    required this.onCancelTimer,
  });

  @override
  ConsumerState<SleepTimerDialog> createState() => _SleepTimerDialogState();
}

class _SleepTimerDialogState extends ConsumerState<SleepTimerDialog> {
  Duration _selectedDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.remainingDuration ?? Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          Expanded(
            child: CupertinoTimerPicker(
              initialTimerDuration: _selectedDuration,
              mode: CupertinoTimerPickerMode.hms,
              onTimerDurationChanged: (time) {
                setState(() {
                  _selectedDuration = time;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: CupertinoButton(
              color: AppTheme.accentColor(ref),
              child: const Text(
                "Set Timer",
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                if (widget.remainingDuration != null) {
                  widget.onCancelTimer();
                } else {
                  Navigator.pop(context);
                  widget.onStartTimer(_selectedDuration);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
