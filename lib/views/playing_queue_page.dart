import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/songs_list_item.dart';

class PlayingQueuePage extends ConsumerStatefulWidget {
  const PlayingQueuePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PlayingQueuePageState();
}

class _PlayingQueuePageState extends ConsumerState<PlayingQueuePage> {
  Box<Songs> playMeBox = Hive.box('playMe');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "PlayMe",
            style: TextStyle(
              color: AppTheme.accentColor(ref),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: SafeArea(
          child: playMeBox.isEmpty
              ? const Center(
                  child: Text(
                    'Go add something first',
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                itemCount: playMeBox.values.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SongsListItem(
                      songsList: playMeBox.values.toList(),
                      song: playMeBox.values.elementAt(index),
                      index: index,
                      fromPlayMe: true,
                    ),
                  );
                },
              ),
        ));
  }
}
