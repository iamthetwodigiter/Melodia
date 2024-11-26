import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/songs_model.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/player_screen.dart';

class HistoryCards extends ConsumerWidget {
  final List<Songs> history;
  const HistoryCards({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: Text(
            'History',
            style: TextStyle(
              color: AppTheme.accentColor(ref),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.28,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: history.length,
            itemBuilder: (context, index) {
              Songs song = history.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (conetxt) => PlayerScreen(
                        playlist: history,
                        initialIndex: history.indexOf(song),
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10).copyWith(bottom: 0),
                  height: size.height * 0.3,
                  width: size.width * 0.35,
                  child: Column(
                    children: [
                      Container(
                        height: size.height * 0.2,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(
                              song.image,
                            ),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                          height: 0.98,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
