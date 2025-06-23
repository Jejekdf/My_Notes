import 'package:flutter/material.dart';
import 'package:notes/Databases/db_helper.dart';

class AddNotePage extends StatefulWidget {
  final int? noteId;

  const AddNotePage({Key? key, this.noteId}) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final dbHelper = DatabaseHelper();

  bool _isEditMode = false;
  Map<String, dynamic>? _noteData;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Color _selectedColor = Colors.grey[200]!;

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      _isEditMode = true;
      _loadNoteData(widget.noteId!);
    }
  }

  Future<void> _loadNoteData(int id) async {
    final data = await dbHelper.getNoteById(id);
    if (data != null) {
      setState(() {
        _noteData = data;
        _titleController.text = data['title'];
        _contentController.text = data['content'];
        if (data['color'] != null) {
          _selectedColor = Color(data['color']);
        }
      });
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (_isEditMode) {
      await dbHelper.updateNoteWithColor(
        _noteData!['id'],
        title,
        content,
        _selectedColor.value,
      );
    } else {
      await dbHelper.insertNoteWithColor(title, content, _selectedColor.value);
    }

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildColorPicker() {
    final colors = [
      Colors.grey[200]!,
      Colors.yellow[200]!,
      Colors.green[200]!,
      Colors.blue[200]!,
      Colors.pink[200]!,
      Colors.orange[200]!,
    ];

    return Wrap(
      spacing: 12,
      children: colors.map((color) {
        bool isSelected = color == _selectedColor;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey.shade400,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdfbfb),
      appBar: AppBar(
        backgroundColor: const Color(0xFFfdfbfb),
        elevation: 0,
        title: Text(
          _isEditMode ? 'Edit Catatan' : 'Tambah Catatan',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Hapus Catatan"),
                    content: const Text("Yakin ingin menghapus catatan ini?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await dbHelper.deleteNote(widget.noteId!);
                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context, true);
                          }
                        },
                        child: const Text("Hapus"),
                      ),
                    ],
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black87),
            onPressed: _saveNote,
            tooltip: 'Simpan',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Judul',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Isi Catatan',
                    hintStyle: TextStyle(color: Colors.black54),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.palette, color: _selectedColor, size: 36),
                    tooltip: 'Pilih warna background',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pilih Warna Background',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildColorPicker(),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
