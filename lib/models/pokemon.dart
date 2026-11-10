
class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final String image;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.image,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'];

    final officialArtwork =
        sprites['other']['official-artwork']['front_default'];

    final typesList = (json['types'] as List)
        .map((type) => type['type']['name'] as String)
        .toList();

    return Pokemon(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      image: officialArtwork ?? sprites['front_default'] ?? '',
      types: typesList,
    );
  }
}
