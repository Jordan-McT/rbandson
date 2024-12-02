import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_t_d_m_a_text_recognition_app/delivery/delivery_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'dart:math'; // For random time generation
import 'package:intl/intl.dart'; // For date formatting
import 'package:excel/excel.dart'; // For Excel export
import 'dart:io' as io; // For saving files
import 'package:path_provider/path_provider.dart'; // For accessing storage
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:open_file/open_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'dart:typed_data';

class ScheduleWidget extends StatefulWidget {
  final String driverId;

  const ScheduleWidget({super.key, required this.driverId});

  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  Map<DateTime, List<DocumentSnapshot>> _deliveriesByDate = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDeliveriesForDriver();
  }

  Future<void> _fetchDeliveriesForDriver() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('DELIVERY')
          .where('driver', isEqualTo: FirebaseFirestore.instance.doc('USER/${widget.driverId}'))
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No deliveries found for this driver.';
        });
        return;
      }

      Map<DateTime, List<DocumentSnapshot>> deliveriesByDate = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['delivery_date'] != null && data['delivery_date'] is Timestamp) {
          DateTime deliveryDate = (data['delivery_date'] as Timestamp).toDate();
          deliveryDate = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);

          deliveriesByDate.putIfAbsent(deliveryDate, () => []).add(doc);
        }
      }

      setState(() {
        _deliveriesByDate = deliveriesByDate;
        _isLoading = false;
        _selectedDay = _focusedDay;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching deliveries: $e";
      });
    }
  }

  List<DocumentSnapshot> _getDeliveriesForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _deliveriesByDate[normalizedDay] ?? [];
  }

  Future<void> _generateExcelFile() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch driver-specific deliveries
      QuerySnapshot deliverySnapshot = await firestore
          .collection('DELIVERY')
          .where('driver', isEqualTo: FirebaseFirestore.instance.doc('USER/${widget.driverId}'))
          .get();

      if (deliverySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No deliveries available for export.')),
        );
        return;
      }

      // Create a new Excel workbook
      var excel = Excel.createExcel();
      Sheet sheet = excel['DELIVERY'];

      // Add header row
      sheet.appendRow(['Client', 'Delivery Date', 'Driver', 'Items', 'Status']);

      // Add delivery data
      for (var doc in deliverySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Resolve client name from DocumentReference
        String client = 'Unknown Client';
        if (data['client'] is DocumentReference) {
          var clientDoc = await (data['client'] as DocumentReference).get();
          client = (clientDoc.data() as Map<String, dynamic>?)?['client_name'] ?? 'Unknown Client';
        } else if (data['client'] is String) {
          client = data['client'];
        }

        // Resolve driver name from DocumentReference
        String driver = 'Unknown Driver';
        if (data['driver'] is DocumentReference) {
          var driverDoc = await (data['driver'] as DocumentReference).get();
          driver = (driverDoc.data() as Map<String, dynamic>?)?['display_name'] ?? 'Unknown Driver';
        } else if (data['driver'] is String) {
          driver = data['driver'];
        }

        // Resolve items list from DocumentReferences
        String items = 'No Items';
        if (data['items'] is List) {
          var itemNames = await Future.wait(
            (data['items'] as List).map((itemRef) async {
              if (itemRef is DocumentReference) {
                var itemDoc = await itemRef.get();
                return (itemDoc.data() as Map<String, dynamic>?)?['item_name'] ?? 'Unknown Item';
              } else if (itemRef is String) {
                return itemRef;
              }
              return 'Unknown Item';
            }),
          );
          items = itemNames.join(', ');
        }

        // Convert and format delivery date
        DateTime? deliveryDate = data['delivery_date'] != null
            ? (data['delivery_date'] as Timestamp).toDate()
            : null;
        String formattedDate = deliveryDate != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(deliveryDate)
            : 'N/A';

        // Resolve status
        String status = data['status'] != null ? data['status'].toString() : 'Unknown';

        // Append row to Excel sheet
        sheet.appendRow([client, formattedDate, driver, items, status]);
      }

      // Encode the Excel file
      final List<int> excelBytes = excel.encode()!;

      // Save to the Downloads directory
      final io.Directory directory = io.Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }
      final String filePath = '${directory.path}/delivery_data.xlsx';

      // Save the Excel file
      final io.File file = io.File(filePath);
      await file.writeAsBytes(excelBytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excel file saved to Downloads: $filePath')),
      );

      // Open the file using the default app on the device
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate Excel file: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).alternate,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_ios,
            color: FlutterFlowTheme.of(context).primary,
            size: 24.0,
          ),
          onPressed: () {
            context.goNamed('Landing');
          },
        ),
        title: Text(
          'Schedule',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'Work Sans',
            color: FlutterFlowTheme.of(context).primary,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/RB_&_Son_Fleet.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Background opacity
              BlendMode.darken,
            ),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            color: Colors.white, // White text for readability
                          ),
                    ),
                  )
                : Column(
                    children: [
                      TableCalendar(
                        focusedDay: _focusedDay,
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2030),
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        eventLoader: _getEventMarkersForDay,
                        calendarFormat: CalendarFormat.month,
                        headerStyle: HeaderStyle(
                          titleTextStyle: FlutterFlowTheme.of(context).titleLarge.override(
                                color: Colors.white,
                              ),
                          leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                          formatButtonVisible: false,
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.white),
                          weekendStyle: TextStyle(color: Colors.white),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).green,
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).tertiary,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: FlutterFlowTheme.of(context).bodyText1.override(
                                color: Colors.white,
                              ),
                          weekendTextStyle: FlutterFlowTheme.of(context).bodyText1.override(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: _generateExcelFile,
                        child: const Text('Export to Excel'),
                      ),
                      Expanded(
                        child: _selectedDay != null
                            ? _buildDeliveryListForSelectedDay()
                            : Center(
                                child: Text(
                                  'Please select a date.',
                                  style: FlutterFlowTheme.of(context).bodyText1.override(
                                        color: Colors.white, // White text for readability
                                      ),
                                ),
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDeliveryListForSelectedDay() {
    final deliveries = _getDeliveriesForDay(_selectedDay!);

    if (deliveries.isEmpty) {
      return Center(
        child: Text(
          'No deliveries for selected date.',
          style: FlutterFlowTheme.of(context).bodyText1.override(
                color: Colors.white, // White text for visibility on background
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        final data = delivery.data() as Map<String, dynamic>;
        final bool isComplete = data['status'] == true; // Check delivery status
        final clientRef = data['client'] as DocumentReference?;

        return FutureBuilder<String>(
          future: clientRef != null
              ? _fetchClientAndLocation(clientRef)
              : Future.value('Unknown Client - Location Unknown'),
          builder: (context, snapshot) {
            final clientAndLocation = snapshot.data ?? 'Unknown Client - Location Unknown';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  _navigateToDeliveryDetailPage(delivery);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplete ? Colors.green : Colors.red, // Dynamic color
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      clientAndLocation,
                      style: FlutterFlowTheme.of(context).bodyText1.override(
                            color: FlutterFlowTheme.of(context).primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _getEventMarkersForDay(DateTime day) {
    final deliveries = _getDeliveriesForDay(day);

    if (deliveries.isEmpty) {
      return [];
    }

    final allComplete = deliveries.every((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['status'] != true;
    });

    return [
      Container(
        width: 7.0,
        height: 7.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: allComplete ? Colors.black : Colors.red,
        ),
      ),
    ];
  }

  void _navigateToDeliveryDetailPage(DocumentSnapshot deliveryDoc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryWidget(
          deliveryDocumentSnapshot: deliveryDoc,
          delivery: deliveryDoc.data() as Map<String, dynamic>,
        ),
      ),
    );
  }

  Future<String> _fetchClientAndLocation(DocumentReference clientRef) async {
    try {
      DocumentSnapshot clientDoc = await clientRef.get();
      String clientName = clientDoc.get('client_name') ?? 'Unknown Client';

      DocumentReference? locationRef = clientDoc.get('location');
      if (locationRef == null) return '$clientName - Location Unknown';

      DocumentSnapshot locationDoc = await locationRef.get();
      if (!locationDoc.exists) return '$clientName - Location Unknown';

      String streetNumber = locationDoc.get('street_number').toString();
      String streetName = locationDoc.get('street_name') ?? '';
      String city = locationDoc.get('city') ?? '';
      String province = locationDoc.get('province') ?? '';

      return '$clientName - $streetNumber $streetName';
    } catch (e) {
      print("Error fetching client or location: $e");
      return 'Unknown Client - Location Error';
    }
  }
}
