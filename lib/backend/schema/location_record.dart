import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class LocationRecord extends FirestoreRecord {
  LocationRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "street_number" field.
  int? _streetNumber;
  int get streetNumber => _streetNumber ?? 0;
  bool hasStreetNumber() => _streetNumber != null;

  // "street_name" field.
  String? _streetName;
  String get streetName => _streetName ?? '';
  bool hasStreetName() => _streetName != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "province" field.
  Province? _province;
  Province? get province => _province;
  bool hasProvince() => _province != null;

  void _initializeFields() {
    _streetNumber = castToType<int>(snapshotData['street_number']);
    _streetName = snapshotData['street_name'] as String?;
    _city = snapshotData['city'] as String?;
    _province = deserializeEnum<Province>(snapshotData['province']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('LOCATION');

  static Stream<LocationRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LocationRecord.fromSnapshot(s));

  static Future<LocationRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LocationRecord.fromSnapshot(s));

  static LocationRecord fromSnapshot(DocumentSnapshot snapshot) =>
      LocationRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LocationRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LocationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LocationRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LocationRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLocationRecordData({
  int? streetNumber,
  String? streetName,
  String? city,
  Province? province,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'street_number': streetNumber,
      'street_name': streetName,
      'city': city,
      'province': province,
    }.withoutNulls,
  );

  return firestoreData;
}

class LocationRecordDocumentEquality implements Equality<LocationRecord> {
  const LocationRecordDocumentEquality();

  @override
  bool equals(LocationRecord? e1, LocationRecord? e2) {
    return e1?.streetNumber == e2?.streetNumber &&
        e1?.streetName == e2?.streetName &&
        e1?.city == e2?.city &&
        e1?.province == e2?.province;
  }

  @override
  int hash(LocationRecord? e) => const ListEquality()
      .hash([e?.streetNumber, e?.streetName, e?.city, e?.province]);

  @override
  bool isValidKey(Object? o) => o is LocationRecord;
}
