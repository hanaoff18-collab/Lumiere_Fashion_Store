import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseDataService {
  FirebaseDataService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? phone,
    /// When true, writes [phone] to Firestore (empty string removes the field).
    bool mergePhone = false,
  }) async {
    final data = <String, dynamic>{
      'email': email,
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (mergePhone) {
      final p = phone ?? '';
      data['phone'] = p.isEmpty ? FieldValue.delete() : p;
    }
    await _firestore.collection('users').doc(uid).set(
          data,
          SetOptions(merge: true),
        );
  }

  Future<String> uploadProfileImage({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage.ref('users/$uid/profile.jpg');
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return ref.getDownloadURL();
  }

  Future<void> saveProductFavorite({
    required String uid,
    required String productId,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .set({
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
