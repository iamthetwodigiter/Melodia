import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/models/homepage_model.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/views/albums_page.dart';

class NewAlbumsCards extends ConsumerWidget {
  final dynamic newAlbumData;
  const NewAlbumsCards({
    super.key,
    required this.newAlbumData,
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
            'New Albums',
            style: TextStyle(
              color: AppTheme.accentColor(ref),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: size.height * 0.35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newAlbumData.length,
            itemBuilder: (context, index) {
              NewAlbums albumItem = newAlbumData.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (conetxt) => AlbumsPage(
                        albumID: albumItem.albumID,
                      ),
                    ),
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
                          height: size.height * 0.25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                albumItem.image,
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          albumItem.title,
                          style: const TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                            height: 0.98,
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${albumItem.year} • ${albumItem.language.toUpperCase()}',
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
