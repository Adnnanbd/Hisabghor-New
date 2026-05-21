import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class CloudBackupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get userId => _auth.currentUser?.uid ?? 'anonymous';

  // Backup Data to Firestore
  Future<void> backupToCloud() async {
    if (_auth.currentUser == null) {
      throw Exception('User not logged in');
    }

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);

    // Backup Products
    final productBox = await Hive.openBox('products');
    for (var key in productBox.keys) {
      final docRef = userRef.collection('products').doc(key.toString());
      batch.set(docRef, productBox.get(key));
    }

    // Backup Customers
    final customerBox = await Hive.openBox('customers');
    for (var key in customerBox.keys) {
      final docRef = userRef.collection('customers').doc(key.toString());
      batch.set(docRef, customerBox.get(key));
    }

    // Backup Sales
    final salesBox = await Hive.openBox('sales');
    for (var key in salesBox.keys) {
      final docRef = userRef.collection('sales').doc(key.toString());
      batch.set(docRef, salesBox.get(key));
    }

    await batch.commit();
    print('Backup completed successfully');
  }

  // Restore Data from Firestore
  Future<void> restoreFromCloud() async {
    if (_auth.currentUser == null) {
      throw Exception('User not logged in');
    }

    final userRef = _firestore.collection('users').doc(userId);

    // Restore Products
    final productBox = await Hive.openBox('products');
    final productsSnapshot = await userRef.collection('products').get();
    for (var doc in productsSnapshot.docs) {
      await productBox.put(doc.id, doc.data());
    }

    // Restore Customers
    final customerBox = await Hive.openBox('customers');
    final customersSnapshot = await userRef.collection('customers').get();
    for (var doc in customersSnapshot.docs) {
      await customerBox.put(doc.id, doc.data());
    }

    // Restore Sales
    final salesBox = await Hive.openBox('sales');
    final salesSnapshot = await userRef.collection('sales').get();
    for (var doc in salesSnapshot.docs) {
      await salesBox.put(doc.id, doc.data());
    }

    print('Restore completed successfully');
  }
}
