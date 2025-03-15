import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodia/providers/offline_audio_provider.dart';
import 'package:melodia/providers/offline_files_provider.dart';
import 'package:melodia/utils/colors.dart';
import 'package:melodia/widgets/music_slab.dart';
import 'package:melodia/widgets/offline_song_list_item.dart';

class MusicPage extends ConsumerStatefulWidget {
  final bool isDownloadsFolder;

  const MusicPage({
    super.key,
    required this.isDownloadsFolder,
  });

  @override
  ConsumerState<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends ConsumerState<MusicPage> {
  final Set<int> _selectedIndices = {};
  bool _selectionMode = false;

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIndices.clear();
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _deleteSelectedSongs(WidgetRef ref) {
    final notifier = ref.watch(filesProvider.notifier);
    final files = ref.watch(filesProvider);
    final audioPlayer = ref.watch(offlineAudioPlayerProvider);
    final audioNotifier = ref.watch(offlineAudioPlayerProvider.notifier);

    if (_selectedIndices.contains(audioPlayer.currentIndex)) {
      audioNotifier.stop();
    }

    final selectedSongs =
        _selectedIndices.map((i) => files[i].downloadUrl).toList();
    notifier.deleteSong(selectedSongs);
    notifier.refreshFiles;

    setState(() {
      _selectedIndices.clear();
      _selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final files = ref.watch(filesProvider);
    final notifier = ref.watch(filesProvider.notifier);

    final filteredSongs = files.where((song) {
      if (widget.isDownloadsFolder) {
        return song.downloadUrl.contains('/Music/Melodia');
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isDownloadsFolder ? "Downloads" : "All Songs",
          style: TextStyle(
            color: AppTheme.accentColor(ref),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: _selectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteSelectedSongs(ref);
                  },
                ),
                IconButton(
                  onPressed: () {
                    List<int> allIndices =
                        List.generate(files.length, (index) => index);
                    setState(() {
                      if (_selectedIndices.containsAll(allIndices)) {
                        _selectedIndices.clear();
                      } else {
                        _selectedIndices.addAll(allIndices);
                      }
                    });
                  },
                  icon: const Icon(Icons.select_all),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSelectionMode,
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => notifier.refreshFiles,
                ),
              ],
        centerTitle: true,
        toolbarHeight: 50,
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: files.isEmpty
                  ? const Center(
                      child: Text(
                        'No Songs found!!\nTry refreshing the library',
                        style: TextStyle(fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSongs.length,
                      itemBuilder: (context, index) {
                        final file = filteredSongs[index];
                        final isSelected = _selectedIndices.contains(index);
        
                        return GestureDetector(
                          onLongPress: () {
                            if (!_selectionMode) {
                              _toggleSelectionMode();
                              _toggleSelection(index);
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                color: isSelected
                                    ? AppTheme.accentColor(ref).withAlpha(50)
                                    : null,
                                child: OfflineSongsListItem(
                                  songList: filteredSongs,
                                  song: file,
                                  index: index,
                                ),
                              ),
                              if (_selectionMode)
                                Positioned(
                                  left: 15,
                                  top: 15,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleSelection(index),
                                    activeColor: AppTheme.accentColor(ref),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const MusicSlab()
          ],
        ),
      ),
    );
  }
}
