
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class MovieService {
  final CollectionReference<Map<String, dynamic>> peliculas =
      FirebaseFirestore.instance.collection('peliculas');

  // Obtener películas en tiempo real
  Stream<List<Movie>> obtenerPeliculas() {
    return peliculas.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Movie.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Agregar película
  Future<void> agregarPelicula(Movie movie) async {
    await peliculas.add({
      ...movie.toMap(),
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }

  // Eliminar película
  Future<void> eliminarPelicula(String id) async {
    await peliculas.doc(id).delete();
  }

  // Consultar película individual
Future<Movie?> obtenerPelicula(String id) async {
  final documento = await peliculas.doc(id).get();

  if (!documento.exists || documento.data() == null) {
    return null;
   }

   return Movie.fromMap(documento.data()!, documento.id);
  } 

Future<void> actualizarPelicula(Movie movie) async {
  await peliculas.doc(movie.id).update({
    ...movie.toMap(),
  });
}
}
