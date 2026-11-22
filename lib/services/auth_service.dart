

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get usuarioActual => _auth.currentUser;

  // Registrar usuario
  Future<UserCredential> registrarUsuario(
    String correo,
    String contrasena,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena,
    );
  }

  // Iniciar sesión
  Future<UserCredential> iniciarSesion(
    String correo,
    String contrasena,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: correo.trim(),
      password: contrasena,
    );
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // Detectar cambios de sesión
  Stream<User?> get cambiosAutenticacion =>
      _auth.authStateChanges();
}
