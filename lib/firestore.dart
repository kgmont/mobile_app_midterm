import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class UserExperience {
  UserExperience({
    required this.id,
    required this.photo,
    required this.name,
  });

  factory UserExperience.fromMap(String id, Map<String, dynamic> data) {
    return UserExperience(id: id, photo: data['photo'], name: data['display_name']);
  }
  final String id;
  final String? photo;
  final String name;
}

class FirebaseService {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  static Map<String, UserExperience> userMap = <String, UserExperience>{};
  final StreamController<Map<String, UserExperience>> _usersController =
  StreamController<Map<String, UserExperience>>();

  FirebaseService() {
    _fs.collection('users').snapshots().listen(_updatedUsers);
  }

  Stream<Map<String, UserExperience>> get users => _usersController.stream;

  void _updatedUsers(QuerySnapshot<Map<String, dynamic>> snapshot) {
    var users = _getSnapshotUsers(snapshot);
    _usersController.add(users);
  }

  Map<String, UserExperience> _getSnapshotUsers(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (var element in snapshot.docs) {
      UserExperience user = UserExperience.fromMap(element.id, element.data());
      userMap[user.id] = user;
    }

    return userMap;
  }
}