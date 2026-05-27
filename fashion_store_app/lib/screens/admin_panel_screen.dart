import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/gradient_app_bar.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: fashionAppBar(
        context,
        'Admin panel',
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Banners'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tab.index == 0) {
            _showProductEditor();
          } else {
            _showBannerEditor();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _ProductsTab(),
          _BannersTab(),
        ],
      ),
    );
  }

  Future<void> _showProductEditor({
    String? id,
    Map<String, dynamic>? initial,
  }) async {
    final name = TextEditingController(text: initial?['name']?.toString() ?? '');
    final desc =
        TextEditingController(text: initial?['description']?.toString() ?? '');
    final price =
        TextEditingController(text: initial?['price']?.toString() ?? '0');
    final category =
        TextEditingController(text: initial?['category']?.toString() ?? '');
    final imageUrl =
        TextEditingController(text: initial?['imageUrl']?.toString() ?? '');
    final imagePath =
        TextEditingController(text: initial?['imagePath']?.toString() ?? '');
    bool isFeatured = initial?['isFeatured'] == true;
    bool active = initial?['active'] != false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      id == null ? 'Add product' : 'Edit product',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
                    const SizedBox(height: 10),
                    TextField(controller: desc, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                    const SizedBox(height: 10),
                    TextField(controller: price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
                    const SizedBox(height: 10),
                    TextField(controller: imageUrl, decoration: const InputDecoration(labelText: 'Image URL')),
                    const SizedBox(height: 10),
                    TextField(controller: imagePath, decoration: const InputDecoration(labelText: 'Storage path (optional)')),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      value: isFeatured,
                      onChanged: (v) => setModal(() => isFeatured = v),
                      title: const Text('Featured'),
                    ),
                    SwitchListTile(
                      value: active,
                      onChanged: (v) => setModal(() => active = v),
                      title: const Text('Active'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async {
                        final payload = <String, dynamic>{
                          'name': name.text.trim(),
                          'description': desc.text.trim(),
                          'price': double.tryParse(price.text.trim()) ?? 0,
                          'category': category.text.trim(),
                          'imageUrl': imageUrl.text.trim(),
                          'imagePath': imagePath.text.trim(),
                          'isFeatured': isFeatured,
                          'active': active,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };
                        final col = FirebaseFirestore.instance.collection('products');
                        if (id == null) {
                          payload['createdAt'] = FieldValue.serverTimestamp();
                          payload['sizes'] = ['S', 'M', 'L', 'XL'];
                          payload['colors'] = ['Black', 'White'];
                          await col.add(payload);
                        } else {
                          await col.doc(id).set(payload, SetOptions(merge: true));
                        }
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showBannerEditor({
    String? id,
    Map<String, dynamic>? initial,
  }) async {
    final title =
        TextEditingController(text: initial?['title']?.toString() ?? '');
    final subtitle =
        TextEditingController(text: initial?['subtitle']?.toString() ?? '');
    final imageUrl =
        TextEditingController(text: initial?['imageUrl']?.toString() ?? '');
    final imagePath =
        TextEditingController(text: initial?['imagePath']?.toString() ?? '');
    final buttonText =
        TextEditingController(text: initial?['buttonText']?.toString() ?? 'Shop now');
    bool active = initial?['active'] != false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                10,
                16,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      id == null ? 'Add banner' : 'Edit banner',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
                    const SizedBox(height: 10),
                    TextField(controller: subtitle, decoration: const InputDecoration(labelText: 'Subtitle')),
                    const SizedBox(height: 10),
                    TextField(controller: imageUrl, decoration: const InputDecoration(labelText: 'Image URL')),
                    const SizedBox(height: 10),
                    TextField(controller: imagePath, decoration: const InputDecoration(labelText: 'Storage path (optional)')),
                    const SizedBox(height: 10),
                    TextField(controller: buttonText, decoration: const InputDecoration(labelText: 'Button text')),
                    const SizedBox(height: 6),
                    SwitchListTile(
                      value: active,
                      onChanged: (v) => setModal(() => active = v),
                      title: const Text('Active'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () async {
                        final payload = <String, dynamic>{
                          'title': title.text.trim(),
                          'subtitle': subtitle.text.trim(),
                          'imageUrl': imageUrl.text.trim(),
                          'imagePath': imagePath.text.trim(),
                          'buttonText': buttonText.text.trim(),
                          'active': active,
                          'updatedAt': FieldValue.serverTimestamp(),
                        };
                        final col = FirebaseFirestore.instance.collection('banners');
                        if (id == null) {
                          payload['createdAt'] = FieldValue.serverTimestamp();
                          await col.add(payload);
                        } else {
                          await col.doc(id).set(payload, SetOptions(merge: true));
                        }
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No products yet'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            return Card(
              child: ListTile(
                title: Text((data['name'] ?? 'Untitled').toString()),
                subtitle: Text('\$${(data['price'] ?? 0).toString()} · ${(data['category'] ?? '-').toString()}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    final state = context.findAncestorStateOfType<_AdminPanelScreenState>();
                    if (v == 'edit') {
                      await state?._showProductEditor(id: doc.id, initial: data);
                    } else {
                      await doc.reference.delete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BannersTab extends StatelessWidget {
  const _BannersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('banners')
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No banners yet'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();
            return Card(
              child: ListTile(
                title: Text((data['title'] ?? 'Untitled').toString()),
                subtitle: Text((data['subtitle'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    final state = context.findAncestorStateOfType<_AdminPanelScreenState>();
                    if (v == 'edit') {
                      await state?._showBannerEditor(id: doc.id, initial: data);
                    } else {
                      await doc.reference.delete();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
