import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class CourseUser {
  const CourseUser({this.id, required this.name, required this.city});

  factory CourseUser.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return CourseUser(
      id: document.id,
      name: data['name'] as String,
      city: data['city'] as String,
    );
  }

  final String? id;
  final String name;
  final String city;

  Map<String, Object> toFields() => {'name': name, 'city': city};
}

class UsersStore {
  UsersStore(FirebaseFirestore firestore)
    : _users = firestore.collection('users');

  final CollectionReference<Map<String, dynamic>> _users;

  static Future<UsersStore> connect() async {
    const projectId = 'demo-flutter-course';
    const host = String.fromEnvironment(
      'FIRESTORE_HOST',
      defaultValue: kIsWeb ? '127.0.0.1' : '10.0.2.2',
    );
    final app = Firebase.apps.isEmpty
        ? await Firebase.initializeApp(
            options: const FirebaseOptions(
              projectId: projectId,
              apiKey: 'demo-key',
              appId: kIsWeb
                  ? '1:1234567890:web:481234567890'
                  : '1:1234567890:android:481234567890',
              messagingSenderId: '1234567890',
            ),
          )
        : Firebase.app();
    final firestore = FirebaseFirestore.instanceFor(app: app);

    // Set this before the first database operation.
    firestore.settings = const Settings(persistenceEnabled: false);
    firestore.useFirestoreEmulator(host, 8080, automaticHostMapping: false);
    return UsersStore(firestore);
  }

  Future<List<CourseUser>> readOnce() async {
    final snapshot = await _users
        .orderBy('name')
        .get(const GetOptions(source: Source.server));
    return snapshot.docs.map(CourseUser.fromDocument).toList();
  }

  Stream<List<CourseUser>> watch() => _users
      .orderBy('name')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(CourseUser.fromDocument).toList());

  Future<void> save(CourseUser user) async {
    final id = user.id;
    if (id == null) {
      await _users.add(user.toFields());
    } else {
      await _users.doc(id).update(user.toFields());
    }
  }

  Future<void> delete(String id) => _users.doc(id).delete();
}
