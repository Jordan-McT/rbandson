import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // For random time generation
import 'package:intl/intl.dart'; // For date formatting

// Function to parse DD/MM/YYYY date format with error handling
DateTime parseDate(String dateString) {
  try {
    final format = DateFormat('dd/MM/yyyy'); // Expecting DD/MM/YYYY format
    return format.parseStrict(dateString); // Parse the date strictly
  } catch (e) {
    throw FormatException("Error parsing date: $dateString. Ensure it follows the DD/MM/YYYY format.");
  }
}

// Parse delivery date and add a random time between 08:00 and 17:00
DateTime parseDeliveryDate(String dateString) {
  DateTime parsedDate = parseDate(dateString);

  // Add a random time (hour between 8-16 and random minutes)
  Random random = Random();
  int randomHour = random.nextInt(9) + 8; // Random hour between 8 and 16 inclusive
  int randomMinute = random.nextInt(60); // Random minute

  // Combine date with random time
  return DateTime(
    parsedDate.year,
    parsedDate.month,
    parsedDate.day,
    randomHour,
    randomMinute,
  ).toUtc(); // Convert to UTC
}

Future<void> storeDataInDatabase(Map<String, dynamic> data) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Extract client name and first name for matching
  String clientFullName = data['client'];
  String clientFirstName = clientFullName.split(' ')[0];

  // Handle client reference
  DocumentReference? clientRef;
  QuerySnapshot clientSnapshot = await firestore
      .collection('CLIENT')
      .where('client_name', isGreaterThanOrEqualTo: clientFirstName)
      .where('client_name', isLessThanOrEqualTo: clientFirstName + '\uf8ff')
      .limit(1)
      .get();

  if (clientSnapshot.docs.isNotEmpty) {
    clientRef = clientSnapshot.docs.first.reference;
    print("Client found: ${clientRef.path}");
  } else {
    print("Client not found. Creating new client document for: $clientFullName");
    clientRef = await firestore.collection('CLIENT').add({
      'client_name': clientFullName, // Store full name
    });
  }

  // Find driver reference
  DocumentReference? driverRef;
  QuerySnapshot driverSnapshot = await firestore
      .collection('USER')
      .where('display_name', isEqualTo: data['driver'])
      .limit(1)
      .get();

  if (driverSnapshot.docs.isNotEmpty) {
    driverRef = driverSnapshot.docs.first.reference;
    print("Driver found: ${driverRef.path}");
  } else {
    throw Exception("Driver not found for name: ${data['driver']}");
  }

  // Find item references
  List<DocumentReference> itemRefs = [];
  for (String itemName in data['items']) {
    QuerySnapshot itemSnapshot = await firestore
        .collection('ITEM')
        .where('item_name', isEqualTo: itemName)
        .limit(1)
        .get();

    if (itemSnapshot.docs.isNotEmpty) {
      itemRefs.add(itemSnapshot.docs.first.reference);
    } else {
      print("Item not found: $itemName");
    }
  }

  // Parse the delivery date and add a random time
  DateTime deliveryDate = parseDeliveryDate(data['delivery_date']);

  // Add the delivery document to Firestore
  await firestore.collection('DELIVERY').add({
    'client': clientRef?.path,
    'delivery_date': Timestamp.fromDate(deliveryDate),
    'driver': driverRef?.path,
    'items': itemRefs.map((ref) => ref.path).toList(),
    'status': data['status'] ?? false, // Default to false if status is not provided
  });

  print("DELIVERY document successfully created!");
}
