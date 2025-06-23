import 'package:flutter/material.dart';
import 'package:notes/Databases/db_helper.dart';
import 'package:notes/screen/add_note_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbHelper = DatabaseHelper();
  bool _isGridMode = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _showSearchField = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showSearchField = true;
      });
    });
  }

  void _loadNotes() {
    setState(() {});
  }

  List<Map<String, dynamic>> _filterNotes(List<Map<String, dynamic>> notes) {
    if (_searchQuery.isEmpty) return notes;

    final query = _searchQuery.toLowerCase();
    return notes.where((note) {
      final title = (note['title'] ?? '').toLowerCase();
      final content = (note['content'] ?? '').toLowerCase();
      return title.contains(query) || content.contains(query);
    }).toList();
  }

  Widget buildNoteCard(Map<String, dynamic> note) {
    
    Color bgColor = Colors.grey[200]!; 
    if (note.containsKey('color') && note['color'] != null) {
      bgColor = Color(note['color']);
    }

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddNotePage(noteId: note['id']),
          ),
        );
        if (result == true) {
          _loadNotes();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              note['title'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(note['content'] ?? '', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Hapus Catatan"),
                          content: const Text(
                            "Yakin ingin menghapus catatan ini?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Batal"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await dbHelper.deleteNote(note['id']);
                                _loadNotes();
                                Navigator.pop(context);
                              },
                              child: const Text("Hapus"),
                            ),
                          ],
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfdfbfb),
      appBar: AppBar(
        backgroundColor: const Color(0xFFfdfbfb),
        elevation: 0,
        centerTitle: false,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          child:
              _showSearchField
                  ? TextField(
                    key: const ValueKey('searchField'),
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari catatan...',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  )
                  : const Text(
                    'My Notes',
                    key: ValueKey('titleText'),
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontSize: 20,
                    ),
                  ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridMode ? Icons.format_list_bulleted : Icons.apps,
              color: Colors.black87,
            ),
            tooltip:
                _isGridMode
                    ? 'Tampilkan dalam bentuk daftar'
                    : 'Tampilkan dalam bentuk grid',
            onPressed: () {
              setState(() {
                _isGridMode = !_isGridMode;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: dbHelper.getAllNotes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Belum ada catatan'));
            } else {
              List<Map<String, dynamic>> allNotes = snapshot.data!;
              List<Map<String, dynamic>> filteredNotes = _filterNotes(allNotes);

              if (filteredNotes.isEmpty && _searchQuery.isNotEmpty) {
                return const Center(child: Text('Tidak ada hasil pencarian'));
              }

              return _isGridMode
                  ? MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return buildNoteCard(note);
                    },
                  )
                  : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: buildNoteCard(note),
                      );
                    },
                  );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF15AFF5),
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 700),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const AddNotePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                );

                return Align(
                  alignment: Alignment.bottomRight, 
                  child: RotationTransition(
                    turns: Tween(
                      begin: 0.9,
                      end: 1.0,
                    ).animate(curved), 
                    child: ScaleTransition(scale: curved, child: child),
                  ),
                );
              },
            ),
          );
          if (result == true) {
            _loadNotes();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
