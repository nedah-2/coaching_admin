import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createDocument(
      String collectionPath, String? docId, Map<String, dynamic> data,
      {String? subCollectionPath}) async {
    try {
      if (subCollectionPath != null) {
        await _db
            .collection(collectionPath)
            .doc(docId)
            .collection(subCollectionPath)
            .doc()
            .set(data);
      } else {
        await _db.collection(collectionPath).doc(docId).set(data);
      }
    } catch (e) {
      print('Error creating document: $e');
    }
  }

  Future<DocumentSnapshot> readDocument(String collectionPath, String docId,
      {String? subCollectionPath}) async {
    try {
      if (subCollectionPath != null) {
        return await _db
            .collection(collectionPath)
            .doc(docId)
            .collection(subCollectionPath)
            .doc()
            .get();
      } else {
        return await _db.collection(collectionPath).doc(docId).get();
      }
    } catch (e) {
      print('Error reading document: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(
      String collectionPath, String docId, Map<String, dynamic> data,
      {String? subCollectionPath, String? subDocId}) async {
    try {
      if (subCollectionPath != null && subDocId != null) {
        await _db
            .collection(collectionPath)
            .doc(docId)
            .collection(subCollectionPath)
            .doc(subDocId)
            .update(data);
      } else {
        await _db.collection(collectionPath).doc(docId).update(data);
      }
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<void> deleteDocument(String collectionPath, String docId,
      {String? subCollectionPath, String? subDocId}) async {
    try {
      if (subCollectionPath != null && subDocId != null) {
        await _db
            .collection(collectionPath)
            .doc(docId)
            .collection(subCollectionPath)
            .doc(subDocId)
            .delete();
      } else {
        await _db.collection(collectionPath).doc(docId).delete();
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Future<QuerySnapshot> readDocuments(String collectionPath,
      {String? docId, String? subCollectionPath}) async {
    try {
      if (docId != null && subCollectionPath != null) {
        return await _db
            .collection(collectionPath)
            .doc(docId)
            .collection(subCollectionPath)
            .get();
      } else if (subCollectionPath == 'meetings') {
        return await _db.collection(collectionPath).orderBy('date').get();
      } else if (subCollectionPath == 'tasks') {
        return await _db.collection(collectionPath).orderBy('deadline').get();
      } else {
        return await _db.collection(collectionPath).get();
      }
    } catch (e) {
      print('Error reading documents: $e');
      rethrow;
    }
  }

  Future<void> deleteSubcollection(
      String documentPath, String subcollection) async {
    final subcollectionRef = _db.collection('$documentPath/$subcollection');

    // Get all documents in the subcollection
    final subcollectionDocs = await subcollectionRef.get();

    // Iterate through each document in the subcollection and delete it
    if (subcollectionDocs.docs.isNotEmpty) {
      for (final doc in subcollectionDocs.docs) {
        await subcollectionRef.doc(doc.id).delete();
      }
    }
  }

  Future<void> deleteStudentWithSubcollections(String studentId) async {
    final studentDocPath = 'students/$studentId';

    // Delete tasks subcollection
    await deleteSubcollection(studentDocPath, 'tasks');

    // Delete meetings subcollection
    await deleteSubcollection(studentDocPath, 'meetings');

    // Finally, delete the student document
    await _db.doc(studentDocPath).delete();
  }

  // Method to get documents by a specific field
  Future<QuerySnapshot> getDocumentsByField(
      String collection, String field, String value) {
    return _db.collection(collection).where(field, isEqualTo: value).get();
  }
}
