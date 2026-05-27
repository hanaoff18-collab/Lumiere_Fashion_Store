import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WishlistProvider extends ChangeNotifier {
  WishlistProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      bindToCurrentUser();
    });
    bindToCurrentUser();
  }

  final Set<String> _favoriteIds = <String>{};
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  StreamSubscription<User?>? _authSub;
  String? _boundUid;

  Set<String> get favoriteIds => _favoriteIds;
  int get count => _favoriteIds.length;

  void bindToCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid == _boundUid) return;
    _sub?.cancel();
    _favoriteIds.clear();
    _boundUid = user?.uid;
    if (user == null) {
      notifyListeners();
      return;
    }
    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .listen((snap) {
      _favoriteIds
        ..clear()
        ..addAll(snap.docs.map((e) => e.id));
      notifyListeners();
    });
  }

  Future<void> toggle(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(productId);

    if (_favoriteIds.contains(productId)) {
      await ref.delete();
    } else {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}
