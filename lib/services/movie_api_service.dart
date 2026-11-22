
import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieApiService {
  static const String _url =
      'https://api.testingapis.com/api/Movies';

  Future<List<Map<String, dynamic>>> obtenerPeliculas() async {
    final respuesta = await http.get(Uri.parse(_url));

    if (respuesta.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(respuesta.body);

      return datos
          .where((pelicula) =>
              pelicula['title'] != null &&
              pelicula['title'].toString().trim().isNotEmpty)
          .map((pelicula) => Map<String, dynamic>.from(pelicula))
          .toList();
    }

    throw Exception(
      'Error al consultar películas: ${respuesta.statusCode}',
    );
  }
}
