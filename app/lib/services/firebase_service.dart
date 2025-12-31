import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create or update a document
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // Get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await _db.collection(collection).doc(docId).get();
  }

  // Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await _db.collection(collection).doc(docId).delete();
  }

  // Stream a collection
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection({
    required String collection,
  }) {
    return _db.collection(collection).snapshots();
  }
}
