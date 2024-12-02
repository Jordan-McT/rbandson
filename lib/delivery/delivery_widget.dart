import 'package:i_t_d_m_a_text_recognition_app/main.dart';

import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_data_table.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'delivery_model.dart';
export 'delivery_model.dart';

class DeliveryWidget extends StatefulWidget {
  final Map<String, dynamic> delivery;
  final DocumentSnapshot deliveryDocumentSnapshot; // Pass delivery document directly

  const DeliveryWidget({
    super.key,
    required this.deliveryDocumentSnapshot,
    required this.delivery,
  });

  @override
  State<DeliveryWidget> createState() => _DeliveryWidgetState();
}


class _DeliveryWidgetState extends State<DeliveryWidget> {
  late DeliveryModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _allItemsWithClientInfo = [];
  Map<String, dynamic>? _selectedClientInfo;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DeliveryModel());

    // Directly use the passed 'widget.delivery' to load data
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      try {
        await _loadDeliveryInfo();
        safeSetState(() {}); // Update UI after loading data
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    });
  }

  Future<void> _loadDeliveryInfo() async {
    var delivery = widget.delivery; // Directly use the passed delivery document

    // Assuming `delivery['client']` is a reference to the client document
    var clientDoc = await delivery['client']?.get();
    var clientData = clientDoc?.data() as Map<String, dynamic>?;

    // Assuming `delivery['location']` is a reference to the location document
    var locationDoc = await (clientData?['location'] as DocumentReference?)?.get();
    var locationData = locationDoc?.data() as Map<String, dynamic>?;

    // Convert delivery date (assuming it's a Timestamp)
    DateTime? deliveryDate;
    if (delivery['delivery_date'] != null) {
      deliveryDate = (delivery['delivery_date'] as Timestamp).toDate();
    }

    // Collect items related to the delivery
    Map<String, Map<String, dynamic>> groupedItems = {};
    for (var itemRef in delivery['items'] ?? []) {
      var itemDoc = await itemRef.get();
      var itemData = itemDoc.data() as Map<String, dynamic>? ?? {};
      String itemName = itemData['item_name'] ?? 'Unknown Item';
      int price = itemData['price'] ?? 0;

      if (groupedItems.containsKey(itemName)) {
        groupedItems[itemName]!['quantity'] += 1;
        groupedItems[itemName]!['price'] += price;
      } else {
        groupedItems[itemName] = {
          'item': itemData,
          'quantity': 1,
          'price': price,
          'clientName': clientData?['client_name'] ?? 'Unknown Client',
          'location': locationData,
          'deliveryDate': deliveryDate,  // Use the DateTime object here
          'deliveryStatus': delivery['status'],  // Access directly from delivery
        };
      }
    }

    _allItemsWithClientInfo = groupedItems.values.toList();
    setState(() {
      // Set initial client information to display
      _selectedClientInfo = _allItemsWithClientInfo.isNotEmpty
          ? _allItemsWithClientInfo.first
          : null;
    });
  }

  void _updateClientInfo(Map<String, dynamic> itemWithClientInfo) {
    setState(() {
      _selectedClientInfo = itemWithClientInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).alternate,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_ios,
              color: FlutterFlowTheme.of(context).primary,
              size: 30.0,
            ),
            onPressed: () async {
              context.pushNamed('Schedule'); // Navigate back to Landing page
            },
          ),
          title: Text(
            'View Delivery',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Work Sans',
                  color: FlutterFlowTheme.of(context).primary,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Stack(
            children: [
              // Background Image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/RB_&_Son_Fleet.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.1),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _selectedClientInfo?['clientName'] ?? 'CLIENT_NAME',
                          style: FlutterFlowTheme.of(context).headlineMedium.override(
                                fontFamily: 'Work Sans',
                                color: FlutterFlowTheme.of(context).green,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8.0),
                        
                        Text(
                          _selectedClientInfo?['deliveryDate'] != null
                              ? DateFormat('MMMM d, yyyy, h:mm a').format(
                                  _selectedClientInfo!['deliveryDate'] as DateTime)
                              : 'DELIVERY_DATE', // Fallback if null
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).green,
                              ),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: FlutterFlowTheme.of(context).green,
                            ),
                            Text(
                              _selectedClientInfo?['location'] != null
                                  ? "${_selectedClientInfo!['location']['street_number']} ${_selectedClientInfo!['location']['street_name']}, ${_selectedClientInfo!['location']['city']}, ${_selectedClientInfo!['location']['province']}"
                                  : 'CLIENT_LOCATION',
                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context).green,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: FlutterFlowTheme.of(context).primaryBackground.withOpacity(0.9),
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
                          headingRowColor: MaterialStateProperty.all(FlutterFlowTheme.of(context).alternate),
                          columns: [
                            DataColumn(
                              label: Text(
                                'ITEM',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary, // Dynamically change based on theme
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'QUANTITY',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary, // Dynamically change based on theme
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'COST',
                                style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary, // Dynamically change based on theme
                                ),
                              ),
                            ),
                          ],
                          rows: _allItemsWithClientInfo.map<DataRow>((itemWithClientInfo) {
                            var item = itemWithClientInfo['item'];
                            return DataRow(
                              onSelectChanged: (isSelected) {
                                if (isSelected == true) {
                                  _updateClientInfo(itemWithClientInfo);
                                }
                              },
                              cells: [
                                DataCell(Text('${item['item_name'] ?? 'Unknown Item'} (${item['measurement_size'] ?? ''}${item['measurement_unit'] ?? ''})')),
                                DataCell(Text('${itemWithClientInfo['quantity']}')),
                                DataCell(Text('${itemWithClientInfo['price']}')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Status: ',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                fontWeight: FontWeight.bold,
                                color: FlutterFlowTheme.of(context).white,
                              ),
                        ),
                        const SizedBox(width: 10),
                        
                        ElevatedButton(
                          onPressed: () async {
                            // Toggle the current status
                            bool newStatus = !(widget.delivery['status'] ?? false);
                            
                            try {
                              // Update Firestore document status
                              await widget.deliveryDocumentSnapshot.reference.update({
                                'status': newStatus,
                              });

                              // Update local state to reflect new status immediately
                              setState(() {
                                widget.delivery['status'] = newStatus;
                              });

                              // Show a Snackbar message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Status updated to: ${newStatus ? "Complete" : "Incomplete"}'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error updating status: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.delivery['status'] == true ? Colors.green : Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                          child: Text(
                            widget.delivery['status'] == true ? 'Complete' : 'Incomplete',
                          ),
                        )

                      ],
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on Map<String, dynamic> {
  get reference => null;
}
