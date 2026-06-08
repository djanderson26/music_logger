import 'track.dart';

class Album {

  Album({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artistId,
    required this.tracks, this.year,
    this.coverArtUrl,
  });

  factory Album.fromMap(Map<String, dynamic> map) => Album(
      id: map['id'] as String,
      title: map['title'] as String,
      artistName: map['artistName'] as String,
      artistId: map['artistId'] as String,
      year: map['year'] as int?,
      coverArtUrl: map['coverArtUrl'] as String?,
      tracks: List<Track>.from(
        (map['tracks'] as List<dynamic>? ?? []).map(
          (track) => Track.fromMap(track as Map<String, dynamic>),
        ),
      ),
    );
  final String id; // MusicBrainz release-group ID
  final String title;
  final String artistName;
  final String artistId;
  final int? year;
  final String? coverArtUrl;
  final List<Track> tracks;

  Album copyWith({
    String? id,
    String? title,
    String? artistName,
    String? artistId,
    int? year,
    String? coverArtUrl,
    List<Track>? tracks,
  }) => Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      artistId: artistId ?? this.artistId,
      year: year ?? this.year,
      coverArtUrl: coverArtUrl ?? this.coverArtUrl,
      tracks: tracks ?? this.tracks,
    );

  Map<String, dynamic> toMap() => {
      'id': id,
      'title': title,
      'artistName': artistName,
      'artistId': artistId,
      'year': year,
      'coverArtUrl': coverArtUrl,
      'tracks': tracks.map((track) => track.toMap()).toList(),
    };

  @override
  String toString() => 'Album(id: $id, title: $title, artistName: $artistName, artistId: $artistId, year: $year, coverArtUrl: $coverArtUrl, tracks: $tracks)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          artistName == other.artistName &&
          artistId == other.artistId &&
          year == other.year &&
          coverArtUrl == other.coverArtUrl &&
          tracks == other.tracks;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      artistName.hashCode ^
      artistId.hashCode ^
      year.hashCode ^
      coverArtUrl.hashCode ^
      tracks.hashCode;
}
