import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'delivery_widget.dart' show DeliveryWidget;
import 'package:flutter/material.dart';

class DeliveryModel extends FlutterFlowModel<DeliveryWidget> {
  /// Local state fields for this page.

  DocumentReference? client;
  List<DocumentReference> items = [];
  void addToItems(DocumentReference item) => items.add(item);
  void removeFromItems(DocumentReference item) => items.remove(item);
  void removeAtIndexFromItems(int index) => items.removeAt(index);
  void insertAtIndexInItems(int index, DocumentReference item) =>
      items.insert(index, item);
  void updateItemsAtIndex(int index, Function(DocumentReference) updateFn) =>
      items[index] = updateFn(items[index]);

  String? clientName;
  String? deliveryDate;
  DocumentReference? clientLocation;
  int? numberOfClients;
  int? currentClientNumber;

  // New fields to store the fetched data
  Map<String, dynamic>? locationDetails; // For location details
  List<Map<String, dynamic>>? itemsList; // For items data

  /// State fields for stateful widgets in this page.
  final formKey = GlobalKey<FormState>();

  // Stores action output result for [Firestore Query - Query a collection] action in Delivery widget.
  List<DeliveryRecord>? deliveries;

  // Stores action output result for [Backend Call - Read Document] action in Delivery widget.
  ClientRecord? clientInfo;

  // State field(s) for ItemTable widget.
  final itemTableController = FlutterFlowDataTableController<DocumentReference>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    itemTableController.dispose();
  }
}
