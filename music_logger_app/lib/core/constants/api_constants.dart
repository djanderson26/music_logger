/// API endpoint constants and configuration.
class ApiConstants {
  ApiConstants._();

  // MusicBrainz — no key required; must include User-Agent header
  static const String musicBrainzBase = 'https://musicbrainz.org/ws/2';
  static const String musicBrainzUserAgent =
      'MusicLogger/1.0 (github.com/djanderson26/music_logger)';

  // Cover Art Archive — no key required
  static const String coverArtBase = 'https://coverartarchive.org';

  // Last.fm — key loaded from .env
  static const String lastFmBase = 'https://ws.audioscrobbler.com/2.0';

  // Genius — token loaded from .env
  static const String geniusBase = 'https://api.genius.com';
}
