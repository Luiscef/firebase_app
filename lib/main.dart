import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';
import 'firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseConfig);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas con Firebase',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const NotesPage(),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final FirestoreService _service = FirestoreService();
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Trabajo',
    'Personal',
    'Urgente',
    'Otros',
  ];

  Future<void> _addNote() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _service.addNote(text, _selectedCategory);
    _controller.clear();
    setState(() {
      _selectedCategory = 'General';
    });
  }

  Future<void> _editNote(String id, String oldText, String oldCategory) async {
  final ctrl = TextEditingController(text: oldText);
  // si la categoría no existe, usa "General"
  String newCategory = _categories.contains(oldCategory) ? oldCategory : 'General';

  final result = await showDialog<Map<String, String>>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Editar nota'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Texto'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: newCategory,
            items: _categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            decoration: const InputDecoration(labelText: 'Categoría'),
            onChanged: (val) {
              newCategory = val ?? newCategory;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'text': ctrl.text.trim(),
            'category': newCategory,
          }),
          child: const Text('Guardar'),
        ),
      ],
    ),
  );

  if (result == null || result['text']!.isEmpty) return;

  await _service.updateNote(id, result['text']!, result['category']!);
}


  Future<void> _deleteNote(String id) async {
    await _service.deleteNote(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas con Firebase')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una nota...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addNote(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addNote, child: const Text('Agregar')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.getNotesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data!.docs;
                if (notes.isEmpty) {
                  return const Center(child: Text('Sin notas aún'));
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final doc = notes[i];
                    final data = doc.data() as Map<String, dynamic>;

                    // Manejo seguro de campos
                    final text = data.containsKey('text') ? data['text'] : '';
                    final category = data.containsKey('category')
                        ? data['category']
                        : 'Sin categoría';
                    final timestamp = data.containsKey('createdAt')
                        ? data['createdAt'] as Timestamp?
                        : null;

                    final date = timestamp != null
                        ? DateTime.fromMillisecondsSinceEpoch(
                            timestamp.millisecondsSinceEpoch)
                        : null;
                    final formattedDate = date != null
                        ? '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
                        : 'Sin fecha';

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          text,
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Categoría: $category',
                                style: const TextStyle(fontSize: 14)),
                            Text('Creado: $formattedDate',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        onTap: () => _editNote(doc.id, text, category),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNote(doc.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
