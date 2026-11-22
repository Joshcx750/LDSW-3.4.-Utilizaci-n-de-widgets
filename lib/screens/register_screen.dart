
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmarController =
      TextEditingController();

  bool cargando = false;

  Future<void> registrarUsuario() async {
    final correo = correoController.text.trim();
    final password = passwordController.text;
    final confirmar = confirmarController.text;

    if (correo.isEmpty || password.isEmpty || confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
        ),
      );
      return;
    }

    if (password != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      await _authService.registrarUsuario(correo, password);

      if (!mounted) return;

      // AuthGate detectará la nueva sesión y abrirá el catálogo.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrarse: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => cargando = false);
      }
    }
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
        title: const Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.person_add_alt_1,
                color: Color(0xFFE53935),
                size: 75,
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Únete a CineManía',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Crea tu cuenta para descubrir nuestro catálogo.',
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 30),

            campoTexto(
              controller: correoController,
              etiqueta: 'Correo electrónico',
              icono: Icons.email,
              tipo: TextInputType.emailAddress,
            ),

            const SizedBox(height: 20),

            campoTexto(
              controller: passwordController,
              etiqueta: 'Contraseña',
              icono: Icons.lock,
              oculto: true,
            ),

            const SizedBox(height: 20),

            campoTexto(
              controller: confirmarController,
              etiqueta: 'Confirmar contraseña',
              icono: Icons.lock_outline,
              oculto: true,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                ),
                onPressed: cargando ? null : registrarUsuario,
                child: cargando
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('REGISTRARME'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget campoTexto({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    bool oculto = false,
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: oculto,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: etiqueta,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icono, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF252525),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
