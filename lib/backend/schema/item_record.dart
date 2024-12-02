import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ItemRecord extends FirestoreRecord {
  ItemRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "item_name" field.
  String? _itemName;
  String get itemName => _itemName ?? '';
  bool hasItemName() => _itemName != null;

  // "measurement_size" field.
  int? _measurementSize;
  int get measurementSize => _measurementSize ?? 0;
  bool hasMeasurementSize() => _measurementSize != null;

  // "measurement_unit" field.
  Measurement? _measurementUnit;
  Measurement? get measurementUnit => _measurementUnit;
  bool hasMeasurementUnit() => _measurementUnit != null;

  // "quantity" field.
  int? _quantity;
  int get quantity => _quantity ?? 0;
  bool hasQuantity() => _quantity != null;

  // "price" field.
  double? _price;
  double get price => _price ?? 0.0;
  bool hasPrice() => _price != null;

  void _initializeFields() {
    _itemName = snapshotData['item_name'] as String?;
    _measurementSize = castToType<int>(snapshotData['measurement_size']);
    _measurementUnit =
        deserializeEnum<Measurement>(snapshotData['measurement_unit']);
    _quantity = castToType<int>(snapshotData['quantity']);
    _price = castToType<double>(snapshotData['price']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('ITEM');

  static Stream<ItemRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ItemRecord.fromSnapshot(s));

  static Future<ItemRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ItemRecord.fromSnapshot(s));

  static ItemRecord fromSnapshot(DocumentSnapshot snapshot) => ItemRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ItemRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ItemRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ItemRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ItemRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createItemRecordData({
  String? itemName,
  int? measurementSize,
  Measurement? measurementUnit,
  int? quantity,
  double? price,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'item_name': itemName,
      'measurement_size': measurementSize,
      'measurement_unit': measurementUnit,
      'quantity': quantity,
      'price': price,
    }.withoutNulls,
  );

  return firestoreData;
}

class ItemRecordDocumentEquality implements Equality<ItemRecord> {
  const ItemRecordDocumentEquality();

  @override
  bool equals(ItemRecord? e1, ItemRecord? e2) {
    return e1?.itemName == e2?.itemName &&
        e1?.measurementSize == e2?.measurementSize &&
        e1?.measurementUnit == e2?.measurementUnit &&
        e1?.quantity == e2?.quantity &&
        e1?.price == e2?.price;
  }

  @override
  int hash(ItemRecord? e) => const ListEquality().hash([
        e?.itemName,
        e?.measurementSize,
        e?.measurementUnit,
        e?.quantity,
        e?.price
      ]);

  @override
  bool isValidKey(Object? o) => o is ItemRecord;
}
