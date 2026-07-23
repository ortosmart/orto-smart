import 'package:flutter/material.dart';

class AddVarietyPage extends StatefulWidget {
  const AddVarietyPage({super.key});

  @override
  State<AddVarietyPage> createState() => _AddVarietyPageState();
}

class _AddVarietyPageState extends State<AddVarietyPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _plantSpacingController = TextEditingController();
  final _rowSpacingController = TextEditingController();
  final _harvestDaysController = TextEditingController();

  String? _plantingMethod;

  @override
  void dispose() {
    _nameController.dispose();
    _plantSpacingController.dispose();
    _rowSpacingController.dispose();
    _harvestDaysController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Dati validi. Il salvataggio sarà aggiunto nel prossimo passo.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova varietà')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome varietà',
                hintText: 'Esempio: San Marzano',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci il nome della varietà';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _plantingMethod,
              decoration: const InputDecoration(
                labelText: 'Metodo di impianto',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'sowing', child: Text('Semina')),
                DropdownMenuItem(value: 'transplant', child: Text('Trapianto')),
                DropdownMenuItem(
                  value: 'broadcast',
                  child: Text('Semina a spaglio'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _plantingMethod = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plantSpacingController,
              decoration: const InputDecoration(
                labelText: 'Distanza tra le piante',
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rowSpacingController,
              decoration: const InputDecoration(
                labelText: 'Distanza tra le file',
                suffixText: 'cm',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _harvestDaysController,
              decoration: const InputDecoration(
                labelText: 'Giorni al raccolto',
                suffixText: 'giorni',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Salva varietà'),
            ),
          ],
        ),
      ),
    );
  }
}
