import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/providers/watch_history_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            history.isEmpty
                ? const Center(
                    child: Text(
                      'Go play something first',
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SongsListItem(
                          songsList:
                              history,
                          song: history.elementAt(index),
                          index: index,
                          fromPlayMe: true,
                        ),
                      );
                    },
                  ),
            const MusicSlab()
          ],
        ),
      ),
    );
  }
}
