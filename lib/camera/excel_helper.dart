import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> generateExcelFromDatabase() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Add headers 
    sheet.appendRow([
      'Amount', 
      'Client Name', 
      'Delivery Date', 
      'Delivery Location', 
      'Driver Name', 
      'Name', 
      'Status'
    ]);

    // Fetch data
    QuerySnapshot snapshot = await firestore.collection('deliveries').get();
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Use safe access for each field to handle missing or null values
      var amount = data['amount'] ?? 0;
      var clientName = data['client_name'] ?? 'N/A';
      var deliveryDate = data['delivery_date'] ?? 'N/A';
      var deliveryLocation = data['delivery_location'] ?? 'N/A';
      var driverName = data['driver_name'] ?? 'N/A';
      var name = data['name'] ?? 'N/A';
      var status = data['status'] != null && data['status'] == true ? 'True' : 'False';

      // Append 
      sheet.appendRow([
        amount,
        clientName,
        deliveryDate,
        deliveryLocation,
        driverName,
        name,
        status,
      ]);
    }

    // Save Excel file
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/DeliveryData.xlsx';
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.save()!);

    print("Excel file saved at $path");
  } catch (e) {
    print("Error generating Excel file: $e");
  }
}

