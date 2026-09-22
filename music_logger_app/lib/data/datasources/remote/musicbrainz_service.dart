import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../../domain/entities/album.dart';
import '../../../domain/entities/artist.dart';

class MusicBrainzService {
  MusicBrainzService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Album>> searchAlbums(String query) async {
    final uri = Uri.parse('${ApiConstants.musicBrainzBase}/release-group',
    ).replace(
      queryParameters: {
        'query': query,
        'type': 'album',
        'fmt': 'json',
      },
    );

    final decoded = await _getJson(uri);
    final releaseGroups =
        decoded['release-groups'] as List<dynamic>? ?? [];

    return releaseGroups.map((item) {
      final releaseGroup = item as Map<String, dynamic>;
      final credits =
          releaseGroup['artist-credit'] as List<dynamic>? ?? [];
      final credit = credits.isNotEmpty
          ? credits.first as Map<String, dynamic>
          : <String, dynamic>{};
      final artist =
          credit['artist'] as Map<String, dynamic>? ?? {};

      final releaseDate =
          releaseGroup['first-release-date'] as String?;

      return Album(
        id: releaseGroup['id'] as String,
        title: releaseGroup['title'] as String,
        artistName: artist['name'] as String? ?? '',
        artistId: artist['id'] as String? ?? '',
        year: releaseDate == null || releaseDate.length < 4
            ? null
            : int.tryParse(releaseDate.substring(0, 4)),
        coverArtUrl: null,
        tracks: const [],
      );
    }).toList();
  }

  Future<List<Artist>> searchArtists(String query) async {
    final uri = Uri.parse(
      '${ApiConstants.musicBrainzBase}/artist',
    ).replace(
      queryParameters: {
        'query': query,
        'fmt': 'json',
      },
    );

    final decoded = await _getJson(uri);
    final artists = decoded['artists'] as List<dynamic>? ?? [];

    return artists.map((item) {
      final artist = item as Map<String, dynamic>;

      return Artist(
        id: artist['id'] as String,
        name: artist['name'] as String,
        bioSummary: null,
        tags: const [],
        imageUrl: null,
      );
    }).toList();
  }
  
  //Helper to avoid duplicating logic
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': ApiConstants.musicBrainzUserAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw APIException(
          'MusicBrainz request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw APIException('MusicBrainz returned an invalid JSON response');
      }

      return decoded;
    } on APIException {
      rethrow;
    } catch (error) {
      throw APIException(
        'Unable to connect to MusicBrainz',
        cause: error,
      );
    }
  }
}
