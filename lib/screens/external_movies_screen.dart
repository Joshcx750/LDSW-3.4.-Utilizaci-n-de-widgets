
import 'package:flutter/material.dart';
import '../services/movie_api_service.dart';

class ExternalMoviesScreen extends StatefulWidget {
  const ExternalMoviesScreen({super.key});

  @override
  State<ExternalMoviesScreen> createState() =>
      _ExternalMoviesScreenState();
}

class _ExternalMoviesScreenState extends State<ExternalMoviesScreen> {
  final MovieApiService apiService = MovieApiService();

  late Future<List<Map<String, dynamic>>> peliculasFuture;

  @override
  void initState() {
    super.initState();
    peliculasFuture = apiService.obtenerPeliculas();
  }

  void _recargarPeliculas() {
    setState(() {
      peliculasFuture = apiService.obtenerPeliculas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas externas'),
        actions: [
          IconButton(
            onPressed: _recargarPeliculas,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: peliculasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No fue posible consultar las películas.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _recargarPeliculas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final peliculas = snapshot.data ?? [];

          if (peliculas.isEmpty) {
            return const Center(
              child: Text('No se encontraron películas.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final pelicula = peliculas[index];

              final titulo =
                  pelicula['title']?.toString() ?? 'Sin título';
              final director =
                  pelicula['director']?.toString() ?? 'No disponible';
              final anio = pelicula['year']?.toString() ?? '';
              final poster = pelicula['poster']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: SizedBox(
                    width: 65,
                    height: 90,
                    child: poster.startsWith('http')
                        ? Image.network(
                            poster,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.movie, size: 40);
                            },
                          )
                        : const Icon(Icons.movie, size: 40),
                  ),
                  title: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Director: $director\nAño: $anio',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
