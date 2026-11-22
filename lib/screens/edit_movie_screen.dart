
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';

class EditMovieScreen extends StatefulWidget {
  final Movie pelicula;

  const EditMovieScreen({
    super.key,
    required this.pelicula,
  });

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final MovieService movieService = MovieService();

  late final TextEditingController tituloController;
  late final TextEditingController anioController;
  late final TextEditingController directorController;
  late final TextEditingController generoController;
  late final TextEditingController sinopsisController;
  late final TextEditingController imagenController;

  bool guardando = false;

  @override
  void initState() {
    super.initState();

    tituloController =
        TextEditingController(text: widget.pelicula.titulo);
    anioController =
        TextEditingController(text: widget.pelicula.anio.toString());
    directorController =
        TextEditingController(text: widget.pelicula.director);
    generoController =
        TextEditingController(text: widget.pelicula.genero);
    sinopsisController =
        TextEditingController(text: widget.pelicula.sinopsis);
    imagenController =
        TextEditingController(text: widget.pelicula.imagen);
  }

  @override
  void dispose() {
    tituloController.dispose();
    anioController.dispose();
    directorController.dispose();
    generoController.dispose();
    sinopsisController.dispose();
    imagenController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final anio = int.tryParse(anioController.text.trim());

    if (anio == null || anio < 1888 || anio > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un año válido entre 1888 y 2100'),
        ),
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final peliculaActualizada = Movie(
        id: widget.pelicula.id,
        titulo: tituloController.text.trim(),
        anio: anio,
        director: directorController.text.trim(),
        genero: generoController.text.trim(),
        sinopsis: sinopsisController.text.trim(),
        imagen: imagenController.text.trim(),
      );

      await movieService.actualizarPelicula(peliculaActualizada);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película actualizada correctamente'),
        ),
      );

      Navigator.pop(context, peliculaActualizada);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  Widget _campo({
    required String etiqueta,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF242424),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }

              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Editar película'),
        backgroundColor: const Color(0xFF1C1C1C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _campo(
                etiqueta: 'Título',
                controller: tituloController,
              ),
              _campo(
                etiqueta: 'Año',
                controller: anioController,
                keyboardType: TextInputType.number,
              ),
              _campo(
                etiqueta: 'Director',
                controller: directorController,
              ),
              _campo(
                etiqueta: 'Género',
                controller: generoController,
              ),
              _campo(
                etiqueta: 'Sinopsis',
                controller: sinopsisController,
                maxLines: 4,
              ),
              _campo(
                etiqueta: 'URL de la imagen (opcional)',
                controller: imagenController,
                keyboardType: TextInputType.url,
                validator: (value) {
                  final texto = value?.trim() ?? '';

                  if (texto.isEmpty) {
                    return null;
                  }

                  final url = Uri.tryParse(texto);

                  if (url == null ||
                      !url.hasScheme ||
                      !['http', 'https'].contains(url.scheme) ||
                      url.host.isEmpty) {
                    return 'Introduce una URL válida o deja el campo vacío';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: guardando ? null : _guardarCambios,
                  icon: guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    guardando ? 'Guardando...' : 'Guardar cambios',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
