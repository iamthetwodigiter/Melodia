import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/homepage_model.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/playlists_page.dart';

class FeaturedPlaylistsCards extends ConsumerWidget {
  final dynamic featuredPlaylistsData;
  const FeaturedPlaylistsCards({
    super.key,
    required this.featuredPlaylistsData,
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
            'Featured Playlists',
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
            itemCount: featuredPlaylistsData.length,
            itemBuilder: (context, index) {
              FeaturedPlaylists playlistItem =
                  featuredPlaylistsData.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (conetxt) =>
                            PlaylistsPage(playlistID: playlistItem.listID)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(10).copyWith(bottom: 0),
                  // height: size.height * 0.3,
                  // width: size.width * 0.35,
                  child: AspectRatio(
                    aspectRatio: 10/16,
                    child: Column(
                      children: [
                        Container(
                          height: size.height * 0.2,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                playlistItem.image,
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          playlistItem.listName,
                          style: const TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold
                            height: 0.98,
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        // Text(
                        //   '${playlistItem.count} Songs',
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //   ),
                        //   maxLines: 1,
                        //   textAlign: TextAlign.center,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        Text(
                          playlistItem.dataType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${playlistItem.followerCount} 🙎🏻',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
