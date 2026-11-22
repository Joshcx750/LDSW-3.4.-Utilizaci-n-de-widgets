
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';
import 'edit_movie_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie pelicula;

  const MovieDetailScreen({
    super.key,
    required this.pelicula,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie pelicula;

  @override
  void initState() {
    super.initState();
    pelicula = widget.pelicula;
  }

  Future<void> _editarPelicula() async {
    final peliculaActualizada = await Navigator.push<Movie>(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(
          pelicula: pelicula,
        ),
      ),
    );

    if (!mounted) return;

    if (peliculaActualizada != null) {
      setState(() {
        pelicula = peliculaActualizada;
      });
    }
  }

  Future<void> _eliminarPelicula() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar película'),
          content: Text(
            '¿Estás seguro de que deseas eliminar "${pelicula.titulo}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
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
      final movieService = MovieService();

      await movieService.eliminarPelicula(pelicula.id);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Detalle de película'),
        backgroundColor: const Color(0xFF1C1C1C),
        actions: [
          IconButton(
            tooltip: 'Editar película',
            icon: const Icon(
              Icons.edit,
              color: Colors.amber,
            ),
            onPressed: _editarPelicula,
          ),
          IconButton(
            tooltip: 'Eliminar película',
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: _eliminarPelicula,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  pelicula.imagen,
                  height: 350,
                  width: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 350,
                      width: 240,
                      color: Colors.grey.shade800,
                      child: const Icon(
                        Icons.movie,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              pelicula.titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${pelicula.anio}  •  ${pelicula.genero}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Director',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pelicula.director,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sinopsis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pelicula.sinopsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
