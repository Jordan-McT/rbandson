import 'dart:async';
import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DeliveryRecord extends FirestoreRecord {
  DeliveryRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "items" field.
  List<DocumentReference>? _items;
  List<DocumentReference> get items => _items ?? const [];
  bool hasItems() => _items != null;

  // "client" field.
  DocumentReference? _client;
  DocumentReference? get client => _client;
  bool hasClient() => _client != null;

  // "delivery_date" field.
  DateTime? _deliveryDate;
  DateTime? get deliveryDate => _deliveryDate;
  bool hasDeliveryDate() => _deliveryDate != null;

  // "driver" field.
  DocumentReference? _driver;
  DocumentReference? get driver => _driver;
  bool hasDriver() => _driver != null;

  // "status" field.
  bool? _status;
  bool? get status => _status;
  bool hasStatus() => _status != null;

  void _initializeFields() {
    _items = getDataList(snapshotData['items']);
    _client = snapshotData['client'] as DocumentReference?;
    _deliveryDate = snapshotData['delivery_date'] is Timestamp
        ? (snapshotData['delivery_date'] as Timestamp).toDate()
        : snapshotData['delivery_date'] as DateTime?;
    _driver = snapshotData['driver'] as DocumentReference?;
    _status = snapshotData['status'] as bool?; // Initialize status field
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('DELIVERY');

  static Stream<DeliveryRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DeliveryRecord.fromSnapshot(s));

  static Future<DeliveryRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DeliveryRecord.fromSnapshot(s));

  static DeliveryRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DeliveryRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DeliveryRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DeliveryRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DeliveryRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DeliveryRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDeliveryRecordData({
  DocumentReference? client,
  DateTime? deliveryDate,
  DocumentReference? driver,
  bool? status, // Add status as a parameter
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'client': client,
      'delivery_date': deliveryDate,
      'driver': driver,
      'status': status, // Include status in the Firestore data map
    }.withoutNulls,
  );

  return firestoreData;
}

class DeliveryRecordDocumentEquality implements Equality<DeliveryRecord> {
  const DeliveryRecordDocumentEquality();

  @override
  bool equals(DeliveryRecord? e1, DeliveryRecord? e2) {
    const listEquality = ListEquality();
    return listEquality.equals(e1?.items, e2?.items) &&
        e1?.client == e2?.client &&
        e1?.deliveryDate == e2?.deliveryDate &&
        e1?.driver == e2?.driver &&
        e1?.status == e2?.status; // Include status in equality check
  }

  @override
  int hash(DeliveryRecord? e) => const ListEquality()
      .hash([e?.items, e?.client, e?.deliveryDate, e?.driver, e?.status]);

  @override
  bool isValidKey(Object? o) => o is DeliveryRecord;
}
