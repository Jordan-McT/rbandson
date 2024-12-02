import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClientRecord extends FirestoreRecord {
  ClientRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "client_name" field.
  String? _clientName;
  String get clientName => _clientName ?? '';
  bool hasClientName() => _clientName != null;

  // "location" field.
  DocumentReference? _location;
  DocumentReference? get location => _location;
  bool hasLocation() => _location != null;

  void _initializeFields() {
    _clientName = snapshotData['client_name'] as String?;
    _location = snapshotData['location'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('CLIENT');

  static Stream<ClientRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClientRecord.fromSnapshot(s));

  static Future<ClientRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClientRecord.fromSnapshot(s));

  static ClientRecord fromSnapshot(DocumentSnapshot snapshot) => ClientRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClientRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClientRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClientRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClientRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClientRecordData({
  String? clientName,
  DocumentReference? location,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'client_name': clientName,
      'location': location,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClientRecordDocumentEquality implements Equality<ClientRecord> {
  const ClientRecordDocumentEquality();

  @override
  bool equals(ClientRecord? e1, ClientRecord? e2) {
    return e1?.clientName == e2?.clientName && e1?.location == e2?.location;
  }

  @override
  int hash(ClientRecord? e) =>
      const ListEquality().hash([e?.clientName, e?.location]);

  @override
  bool isValidKey(Object? o) => o is ClientRecord;
}
