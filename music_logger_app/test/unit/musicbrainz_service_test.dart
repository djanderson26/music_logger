import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:music_logger_app/core/errors/api_exception.dart';
import 'package:music_logger_app/data/datasources/remote/musicbrainz_service.dart';

void main() {
	test('searchAlbums maps release groups and artist credits', () async {
		Uri? requestedUri;
		Map<String, String>? requestedHeaders;
		final client = MockClient((request) async {
			requestedUri = request.url;
			requestedHeaders = request.headers;
			return http.Response(
				jsonEncode({
					'release-groups': [
						{
							'id': 'blonde-id',
							'title': 'Blonde',
							'first-release-date': '2016-08-20',
							'artist-credit': [
								{
									'name': 'Frank Ocean',
									'artist': {
										'id': 'frank-ocean-id',
										'name': 'Frank Ocean',
									},
								},
							],
						},
					],
				}),
				200,
			);
		});
		final service = MusicBrainzService(client: client);

		final albums = await service.searchAlbums('Blonde & More');

		expect(albums, hasLength(1));
		expect(albums.single.id, 'blonde-id');
		expect(albums.single.title, 'Blonde');
		expect(albums.single.artistName, 'Frank Ocean');
		expect(albums.single.artistId, 'frank-ocean-id');
		expect(albums.single.year, 2016);
		expect(albums.single.tracks, isEmpty);
		expect(requestedUri?.path, '/ws/2/release-group');
		expect(requestedUri?.queryParameters['query'], 'Blonde & More');
		expect(requestedUri?.queryParameters['type'], 'album');
		expect(requestedUri?.queryParameters['fmt'], 'json');
		expect(
			requestedHeaders?['user-agent'],
			'MusicLogger/1.0 (github.com/djanderson26/music_logger)',
		);
	});

	test('searchArtists maps artists', () async {
		final client = MockClient((request) async => http.Response(
					jsonEncode({
						'artists': [
							{
								'id': 'frank-ocean-id',
								'name': 'Frank Ocean',
							},
						],
					}),
					200,
				));
		final service = MusicBrainzService(client: client);

		final artists = await service.searchArtists('Frank Ocean');

		expect(artists, hasLength(1));
		expect(artists.single.id, 'frank-ocean-id');
		expect(artists.single.name, 'Frank Ocean');
		expect(artists.single.tags, isEmpty);
	});

	test('empty result arrays return empty lists', () async {
		final client = MockClient((request) async => http.Response(
					jsonEncode({
						'release-groups': [],
						'artists': [],
					}),
					200,
				));
		final service = MusicBrainzService(client: client);

		expect(await service.searchAlbums('unknown'), isEmpty);
		expect(await service.searchArtists('unknown'), isEmpty);
	});

	test('non-200 responses throw APIException', () async {
		final client = MockClient((request) async => http.Response('failure', 503));
		final service = MusicBrainzService(client: client);

		expect(
			() => service.searchArtists('Frank Ocean'),
			throwsA(
				isA<APIException>().having(
					(exception) => exception.statusCode,
					'statusCode',
					503,
				),
			),
		);
	});

	test('network failures throw APIException', () async {
		final client = MockClient((request) async {
			throw TimeoutException('request timed out');
		});
		final service = MusicBrainzService(client: client);

		expect(
			() => service.searchAlbums('Blonde'),
			throwsA(isA<APIException>()),
		);
	});
}
