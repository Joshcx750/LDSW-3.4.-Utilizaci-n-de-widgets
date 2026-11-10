
import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() =>
      _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {

  final PokemonService service = PokemonService();

  final TextEditingController controller =
      TextEditingController();

  Pokemon? pokemon;

  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    controller.text = 'pikachu';
    searchPokemon();
  }

  Future<void> searchPokemon() async {

    final name = controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Escribe un nombre o número.';
        pokemon = null;
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
      pokemon = null;
    });

    try {

      final result = await service.getPokemon(name);

      if (!mounted) return;

      setState(() {
        pokemon = result;
        loading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),

      appBar: AppBar(
        title: const Text(
          'POKÉDEX',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDC2626),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Text(
              'Explora el mundo Pokémon',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Nombre o número del Pokémon',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => searchPokemon(),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: loading ? null : searchPokemon,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: const Text(
                  'BUSCAR POKÉMON',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (loading)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Consultando PokéAPI...'),
                ],
              ),

            if (errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            if (pokemon != null)
              buildPokemonCard(pokemon!),
          ],
        ),
      ),
    );
  }

  Widget buildPokemonCard(Pokemon p) {

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            Text(
              '#${p.id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (p.image.isNotEmpty)
              Image.network(
                p.image,
                height: 180,
                width: 180,
                fit: BoxFit.contain,

                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 100,
                  );
                },
              ),

            const SizedBox(height: 10),

            Text(
              p.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              children: p.types.map((type) {
                return Chip(
                  label: Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFFDC2626),
                );
              }).toList(),
            ),

            const Divider(height: 30),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [

                Column(
                  children: [
                    const Icon(Icons.height),
                    const SizedBox(height: 5),
                    Text(
                      '${p.height / 10} m',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Altura'),
                  ],
                ),

                Column(
                  children: [
                    const Icon(Icons.monitor_weight),
                    const SizedBox(height: 5),
                    Text(
                      '${p.weight / 10} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Peso'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
