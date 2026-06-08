class Track { // milliseconds

  Track({
    required this.id,
    required this.title,
    required this.position,
    this.durationMs,
  });

  factory Track.fromMap(Map<String, dynamic> map) => Track(
      id: map['id'] as String,
      title: map['title'] as String,
      position: map['position'] as int,
      durationMs: map['durationMs'] as int?,
    );
  final String id;
  final String title;
  final int position;
  final int? durationMs;

  Track copyWith({
    String? id,
    String? title,
    int? position,
    int? durationMs,
  }) => Track(
      id: id ?? this.id,
      title: title ?? this.title,
      position: position ?? this.position,
      durationMs: durationMs ?? this.durationMs,
    );

  Map<String, dynamic> toMap() => {
      'id': id,
      'title': title,
      'position': position,
      'durationMs': durationMs,
    };

  @override
  String toString() => 'Track(id: $id, title: $title, position: $position, durationMs: $durationMs)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          position == other.position &&
          durationMs == other.durationMs;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ position.hashCode ^ durationMs.hashCode;
}
