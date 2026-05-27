import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product.dart';
import '../models/promo_banner.dart';

class CatalogRepository {
  CatalogRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  static final Map<String, String> _downloadUrlCache = <String, String>{};

  Stream<List<Product>> watchProducts() {
    return _firestore
        .collection('products')
        .where('active', isEqualTo: true)
        .snapshots()
        .asyncMap((snap) async {
      final list = <Product>[];
      for (final doc in snap.docs) {
        final map = doc.data();
        final imageUrl = await _resolveImage(map['imageUrl'], map['imagePath']);
        final merged = <String, dynamic>{...map, 'imageUrl': imageUrl};
        list.add(Product.fromMap(doc.id, merged));
      }
      return list;
    });
  }

  Stream<List<PromoBanner>> watchBanners() {
    return _firestore
        .collection('banners')
        .where('active', isEqualTo: true)
        .snapshots()
        .asyncMap((snap) async {
      final list = <PromoBanner>[];
      for (final doc in snap.docs) {
        final map = doc.data();
        final imageUrl = await _resolveImage(map['imageUrl'], map['imagePath']);
        final merged = <String, dynamic>{...map, 'imageUrl': imageUrl};
        list.add(PromoBanner.fromMap(doc.id, merged));
      }
      return list;
    });
  }

  Future<String> _resolveImage(dynamic imageUrl, dynamic imagePath) async {
    final url = (imageUrl ?? '').toString();
    if (url.isNotEmpty) return url;
    final path = (imagePath ?? '').toString();
    if (path.isEmpty) return '';
    final cached = _downloadUrlCache[path];
    if (cached != null && cached.isNotEmpty) return cached;
    final download = await _storage.ref(path).getDownloadURL();
    _downloadUrlCache[path] = download;
    return download;
  }
}
