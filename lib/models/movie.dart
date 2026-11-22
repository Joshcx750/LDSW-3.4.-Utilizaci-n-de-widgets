
class Movie {
  final String id;
  final String titulo;
  final int anio;
  final String director;
  final String genero;
  final String sinopsis;
  final String imagen;

  Movie({
    required this.id,
    required this.titulo,
    required this.anio,
    required this.director,
    required this.genero,
    required this.sinopsis,
    required this.imagen,
  });

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'anio': anio,
      'director': director,
      'genero': genero,
      'sinopsis': sinopsis,
      'imagen': imagen,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map, String documentId) {
    return Movie(
      id: documentId,
      titulo: map['titulo'] ?? '',
      anio: (map['anio'] as num?)?.toInt() ?? 0,
      director: map['director'] ?? '',
      genero: map['genero'] ?? '',
      sinopsis: map['sinopsis'] ?? '',
      imagen: map['imagen'] ?? '',
    );
  }
}
