
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/auth_service.dart';
import '../services/movie_service.dart';
import 'add_movie_screen.dart';
import 'admin_movies_screen.dart';
import 'external_movies_screen.dart';
import 'movie_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final AuthService auth = AuthService();
  final MovieService movieService = MovieService();

  final TextEditingController busquedaController =
      TextEditingController();

  String textoBusqueda = '';

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  void _buscarPeliculas(String texto) {
    setState(() {
      textoBusqueda = texto.trim().toLowerCase();
    });
  }

  void _abrirAdministracion() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminMoviesScreen(),
      ),
    );
  }

  void _agregarPelicula() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddMovieScreen(),
      ),
    );
  }

  void _abrirPeliculasExternas() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExternalMoviesScreen(),
      ),
    );
  }

  Future<void> _cerrarSesion() async {
    await auth.cerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: Colors.white,
        title: const Text(
          'CineManía',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Menú principal',
            icon: const Icon(Icons.menu),
            onSelected: (opcion) {
              switch (opcion) {
                case 'catalogo':
                  // Ya estamos en el catálogo.
                  break;

                case 'externas':
                  _abrirPeliculasExternas();
                  break;

                case 'administrar':
                  _abrirAdministracion();
                  break;

                case 'agregar':
                  _agregarPelicula();
                  break;

                case 'salir':
                  _cerrarSesion();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'catalogo',
                child: ListTile(
                  leading: Icon(Icons.movie),
                  title: Text('Catálogo de películas'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'externas',
                child: ListTile(
                  leading: Icon(Icons.cloud_download),
                  title: Text('Películas externas'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'administrar',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Administrar películas'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'agregar',
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text('Agregar película'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'salir',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_filter,
                    size: 85,
                    color: Color(0xFFE53935),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '¡Bienvenido a CineManía!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Todavía no hay películas en el catálogo.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          final peliculasFiltradas = peliculas.where((pelicula) {
            return pelicula.titulo.toLowerCase().contains(textoBusqueda);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 12,
                  ),
                  child: Text(
                    'Catálogo de películas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Barra de búsqueda
                TextField(
                  controller: busquedaController,
                  onChanged: _buscarPeliculas,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Buscar película por título...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFE53935),
                    ),
                    suffixIcon: textoBusqueda.isNotEmpty
                        ? IconButton(
                            tooltip: 'Limpiar búsqueda',
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              busquedaController.clear();
                              _buscarPeliculas('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF252525),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: peliculasFiltradas.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 65,
                                color: Color(0xFFE53935),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'No se encontraron películas',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Intenta con otro título.',
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          itemCount: peliculasFiltradas.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.58,
                          ),
                          itemBuilder: (context, index) {
                            final pelicula = peliculasFiltradas[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MovieDetailScreen(
                                      pelicula: pelicula,
                                    ),
                                  ),
                                );
                              },
                              child: _PeliculaCard(
                                pelicula: pelicula,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PeliculaCard extends StatelessWidget {
  final Movie pelicula;

  const _PeliculaCard({
    required this.pelicula,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF252525),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: pelicula.imagen.isNotEmpty
                  ? Image.network(
                      pelicula.imagen,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const _ImagenNoDisponible();
                      },
                    )
                  : const _ImagenNoDisponible(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pelicula.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${pelicula.anio} • ${pelicula.genero}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagenNoDisponible extends StatelessWidget {
  const _ImagenNoDisponible();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF303030),
      width: double.infinity,
      child: const Center(
        child: Icon(
          Icons.movie,
          size: 55,
          color: Color(0xFFE53935),
        ),
      ),
    );
  }
}
