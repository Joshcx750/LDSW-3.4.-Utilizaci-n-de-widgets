
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pokemon.dart';

class FirestoreService {
  final CollectionReference pokemones =
      FirebaseFirestore.instance.collection('pokemones');

  Future<void> guardarPokemon(Pokemon pokemon) async {
    await pokemones.doc(pokemon.id.toString()).set({
      'nombre': pokemon.name,
      'numero': pokemon.id,
      'tipos': pokemon.types,
      'altura': pokemon.height,
      'peso': pokemon.weight,
      'imagen': pokemon.image,
      'fechaRegistro': FieldValue.serverTimestamp(),
    });
  }
}
