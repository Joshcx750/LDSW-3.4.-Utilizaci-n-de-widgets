
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonService {

  static const String baseUrl =
      'https://pokeapi.co/api/v2/pokemon/';

  Future<Pokemon> getPokemon(String name) async {

    final url = Uri.parse(
      '$baseUrl${name.toLowerCase().trim()}',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {

      final Map<String, dynamic> data =
          jsonDecode(response.body);

      return Pokemon.fromJson(data);

    } else if (response.statusCode == 404) {

      throw Exception('No se encontró el Pokémon.');

    } else {

      throw Exception(
        'Error del servidor: ${response.statusCode}',
      );
    }
  }
}
