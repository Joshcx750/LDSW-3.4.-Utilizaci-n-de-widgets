
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import 'add_movie_screen.dart';

class AdminMoviesScreen extends StatelessWidget {
  const AdminMoviesScreen({super.key});

  Future<void> _agregarPelicula(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMovieScreen(),
      ),
    );
  }

  Future<void> _eliminarPelicula(
    BuildContext context,
    Movie pelicula,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar película'),
          content: Text(
            '¿Deseas eliminar "${pelicula.titulo}" del catálogo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await MovieService().eliminarPelicula(pelicula.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${pelicula.titulo}" fue eliminada.'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieService = MovieService();

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('Administrar películas'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        tooltip: 'Agregar película',
        onPressed: () => _agregarPelicula(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Movie>>(
        stream: movieService.obtenerPeliculas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE53935),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las películas:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final peliculas = snapshot.data ?? [];

          if (peliculas.isEmpty) {
            return const Center(
              child: Text(
                'No hay películas registradas.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: peliculas.length,
            itemBuilder: (context, index) {
              final pelicula = peliculas[index];

              return Card(
                color: const Color(0xFF252525),
                child: ListTile(
                  leading: pelicula.imagen.isNotEmpty
                      ? Image.network(
                          pelicula.imagen,
                          width: 45,
                          height: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.movie,
                              color: Colors.white70,
                              size: 35,
                            );
                          },
                        )
                      : const Icon(
                          Icons.movie,
                          color: Colors.white70,
                          size: 35,
                        ),
                  title: Text(
                    pelicula.titulo,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${pelicula.anio} • ${pelicula.genero}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    tooltip: 'Eliminar película',
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _eliminarPelicula(context, pelicula);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
