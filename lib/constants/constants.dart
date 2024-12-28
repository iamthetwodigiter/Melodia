const String lastVersion = "v4.5.0";
const String appVersion = "v4.6.0";
const List<Map<String, List<String>>> changelogs = [
  {
    "v4.6.0": [
      "Fixed notification bug where it kept on playing notification sound",
      "Fixed PlayMe title alignment",
      "Moved History section to Library as a separate page",
      "Better history track, now all songs that plays are saved rather than the songs that are clicked to play",
      "Added music slab to PlayMe page",
      "Homepage history cards are now optional, can be hidden",
      "Added a provider to manage PlayMe",
      "Added Play All and Remove All options in PlayMe and History pages",
      "YouTube download quality option removed from settings until further update with downloads",
    ]
  },
  {
    "v4.5.0": [
      "Fixed 'Remove from Playlist' option not showing up [both online and offline]",
      "Removed swipe to remove songs from playlist [both online and offline]",
      "All songs from currently playing queue can be added to PlayMe",
      "Entire album/playlist can be added to PlayMe now",
    ]
  },
  {
    "v4.4.0": [
      "Added changelog dialog",
      "Minor UI fixes",
      "Added support to remove song(s) from current playing queue",
      "Added support for a local playing queue PlayMe",
      "Fixed the issue where songs were not playing if suggestions option was off",
      "Added a persistent music slab, that remembers the playlist you were last listening to",
      "Added OnBackInvokedCallback in manifest",
    ]
  },
  {
    "v4.3.0": [
      "NOTE: Since this is a beta release, YouTube Download feature might not work as expected. While testing it worked fine and was saving it in storage, but support for playing YouTube downloads from Melodia will be added in future",
      "Added End of Playback option in sleep timer",
      "Fixed homepage card image size",
      "Update checker now enables the user to download app from within the settings",
      "Added playing queue provider to manage suggestions and solve clash of original",
      "playlist data with suggestion data",
      "Fixed the issue where the downloads page data update didn't update in All Songs page",
      "Tweaked minor settings page UI parameters for better visuals",
      "YouTube Downloader feature beta release, bugs to be expected",
      "Fixed incorrect song playing when playing a song from different album/ playlist",
      "Fixed incorrect song playing when playing from history",
      "Added changelog section to track updates"
    ]
  },
  {
    "Older versions": ["Visit GitHub or official site to see the changelog"]
  }
];
