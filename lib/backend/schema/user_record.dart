import 'dart:async';
import 'package:collection/collection.dart';
import '/backend/schema/util/firestore_util.dart';
import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserRecord extends FirestoreRecord {
  UserRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "password" field.
  String? _password;
  String get password => _password ?? '';
  bool hasPassword() => _password != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "authorized" field.
  bool? _authorized;
  bool get authorized => _authorized ?? false; // Default to false if null
  bool hasAuthorized() => _authorized != null;

  void _initializeFields() {
    _createdTime = snapshotData['created_time'] as DateTime?;
    _displayName = snapshotData['display_name'] as String?;
    _email = snapshotData['email'] as String?;
    _password = snapshotData['password'] as String?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _role = snapshotData['role'] as String?;
    _uid = snapshotData['uid'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _authorized = snapshotData['authorized'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('USER');

  static Stream<UserRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserRecord.fromSnapshot(s));

  static Future<UserRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserRecord.fromSnapshot(s));

  static UserRecord fromSnapshot(DocumentSnapshot snapshot) => UserRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserRecordData({
  DateTime? createdTime,
  String? displayName,
  String? email,
  String? password,
  String? phoneNumber,
  String? role,
  String? uid,
  String? photoUrl,
  bool? authorized, // New parameter added
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'created_time': createdTime,
      'display_name': displayName,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'role': role,
      'uid': uid,
      'photo_url': photoUrl,
      'authorized': authorized, // Added field
    }.withoutNulls,
  );

  return firestoreData;
}

class UserRecordDocumentEquality implements Equality<UserRecord> {
  const UserRecordDocumentEquality();

  @override
  bool equals(UserRecord? e1, UserRecord? e2) {
    return e1?.createdTime == e2?.createdTime &&
        e1?.displayName == e2?.displayName &&
        e1?.email == e2?.email &&
        e1?.password == e2?.password &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.role == e2?.role &&
        e1?.uid == e2?.uid &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.authorized == e2?.authorized; // Added field
  }

  @override
  int hash(UserRecord? e) => const ListEquality().hash([
        e?.createdTime,
        e?.displayName,
        e?.email,
        e?.password,
        e?.phoneNumber,
        e?.role,
        e?.uid,
        e?.photoUrl,
        e?.authorized, // Added field
      ]);

  @override
  bool isValidKey(Object? o) => o is UserRecord;
}
