
import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/movie_service.dart';

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _formKey = GlobalKey<FormState>();
  final MovieService _movieService = MovieService();

  final tituloController = TextEditingController();
  final anioController = TextEditingController();
  final directorController = TextEditingController();
  final generoController = TextEditingController();
  final sinopsisController = TextEditingController();
  final imagenController = TextEditingController();

  bool guardando = false;

  Future<void> guardarPelicula() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => guardando = true);

    try {
      final pelicula = Movie(
        id: '',
        titulo: tituloController.text.trim(),
        anio: int.parse(anioController.text.trim()),
        director: directorController.text.trim(),
        genero: generoController.text.trim(),
        sinopsis: sinopsisController.text.trim(),
        imagen: imagenController.text.trim(),
      );

      await _movieService.agregarPelicula(pelicula);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Película agregada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar película: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => guardando = false);
      }
    }
  }

  Widget campoTexto({
    required String etiqueta,
    required TextEditingController controller,
    int maxLineas = 1,
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validar,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLineas,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: etiqueta,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF252525),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: validar ??
            (valor) {
              if (valor == null || valor.trim().isEmpty) {
                return 'Este campo es obligatorio';
              }
              return null;
            },
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('Agregar película'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(
                Icons.movie_creation,
                color: Color(0xFFE53935),
                size: 65,
              ),
              const SizedBox(height: 20),

              campoTexto(
                etiqueta: 'Título',
                controller: tituloController,
              ),

              campoTexto(
                etiqueta: 'Año',
                controller: anioController,
                tipo: TextInputType.number,
                validar: (valor) {
                  final anio = int.tryParse(valor ?? '');

                  if (anio == null || anio < 1888 || anio > 2100) {
                    return 'Introduce un año válido';
                  }

                  return null;
                },
              ),

              campoTexto(
                etiqueta: 'Director',
                controller: directorController,
              ),

              campoTexto(
                etiqueta: 'Género',
                controller: generoController,
              ),

              campoTexto(
                etiqueta: 'Sinopsis',
                controller: sinopsisController,
                maxLineas: 4,
              ),

              campoTexto(
                etiqueta: 'URL de imagen del póster (opcional)',
                controller: imagenController,
                validar: (valor) {
                  final texto = valor?.trim() ?? '';

                  // Si está vacío, se acepta.
                  if (texto.isEmpty) {
                    return null;
                  }

                  // Si tiene contenido, debe ser una URL válida.
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
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: guardando ? null : guardarPelicula,
                  child: guardando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('GUARDAR PELÍCULA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
