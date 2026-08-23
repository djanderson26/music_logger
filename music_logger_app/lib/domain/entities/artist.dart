class Artist {

  Artist({
    required this.id,
    required this.name,
    required this.tags, this.bioSummary,
    this.imageUrl,
  });

  factory Artist.fromMap(Map<String, dynamic> map) => Artist(
      id: map['id'] as String,
      name: map['name'] as String,
      bioSummary: map['bioSummary'] as String?,
      tags: List<String>.from(map['tags'] as List<dynamic>? ?? []),
      imageUrl: map['imageUrl'] as String?,
    );
    
  final String id;
  final String name;
  final String? bioSummary;
  final List<String> tags;
  final String? imageUrl;

  Artist copyWith({
    String? id,
    String? name,
    String? bioSummary,
    List<String>? tags,
    String? imageUrl,
  }) => Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      bioSummary: bioSummary ?? this.bioSummary,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
    );

  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'bioSummary': bioSummary,
      'tags': tags,
      'imageUrl': imageUrl,
    };

  @override
  String toString() => 'Artist(id: $id, name: $name, bioSummary: $bioSummary, tags: $tags, imageUrl: $imageUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Artist &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          bioSummary == other.bioSummary &&
          tags == other.tags &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ bioSummary.hashCode ^ tags.hashCode ^ imageUrl.hashCode;
}
