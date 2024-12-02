import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'camera_model.dart';
export 'camera_model.dart';
import 'database_helper.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CameraModel());
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController?.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera found')),
      );
    }
  }

  Future<void> _captureAndRecognizeText() async {
  if (!_isCameraInitialized || _cameraController == null) return;

  try {
    // Capture the image
    final image = await _cameraController!.takePicture();

    // Load image
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer();

    // Process the image
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close(); // Close recognizer after use

    // Extract and format recognized text
    Map<String, dynamic> extractedData = _extractRelevantData(recognizedText);

    // Save to database
    await storeDataInDatabase(extractedData);

    // Show preview
    _showRecognizedData(extractedData);
  } catch (e) {
    print('Error capturing image or recognizing text: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to recognize text.')),
    );
  }
}

  Map<String, dynamic> _extractRelevantData(RecognizedText recognizedText) {
    Map<String, dynamic> extractedData = {
      'client': '',
      'delivery_date': '',
      'driver': '',
      'items': [],
      'status': false,
    };

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        String lineText = line.text.toLowerCase();

        if (lineText.contains("client:")) {
          // Start with the first part of the client name
          String clientName = lineText.split("client:")[1].trim();

          // Check subsequent lines for more name parts
          int lineIndex = block.lines.indexOf(line);
          if (lineIndex + 1 < block.lines.length) {
            String nextLine = block.lines[lineIndex + 1].text.trim();
            // Append the next line if it’s not another field like "driver:"
            if (!nextLine.toLowerCase().contains(':')) {
              clientName += " $nextLine";
            }
          }

          extractedData['client'] = clientName;
        }
        else if (lineText.contains("delivery date:")) {
          extractedData['delivery_date'] = line.text.split(":")[1].trim();
        }
        else if (lineText.contains("driver:")) {
          extractedData['driver'] = line.text.split(":")[1].trim();
        }
        else if (lineText.contains("items:")) {
          // Extract items as a comma-separated list
          extractedData['items'] = line.text.split(":")[1].trim().split(',').map((e) => e.trim()).toList();
        }
        else if (lineText.contains("status:")) {
          extractedData['status'] = line.text.split(":")[1].trim().toLowerCase() == 'true';
        }
      }
    }

    return extractedData;
  }

// Helper function to extract the value after the field
  String _extractFieldValue(String lineText, String fieldName) {
    return lineText.split(fieldName)[1].trim(); // Handles multi-word names
  }




  void _showRecognizedData(Map<String, dynamic> data) {
    TextEditingController clientController =
    TextEditingController(text: data['client_name']);
    TextEditingController dateController =
    TextEditingController(text: data['delivery_date']);
    TextEditingController driverController =
    TextEditingController(text: data['driver_name']);
    TextEditingController itemsController =
    TextEditingController(text: (data['items'] as List).join(', '));
    TextEditingController statusController =
    TextEditingController(text: data['status'] ? 'true' : 'false');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Recognized Data'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditableField('Client', clientController),
                _buildEditableField('Delivery Date', dateController),
                _buildEditableField('Driver', driverController),
                _buildEditableField('Items (comma-separated)', itemsController),
                _buildEditableField('Status (true/false)', statusController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Map<String, dynamic> updatedData = {
                  'client_name': clientController.text.trim(),
                  'delivery_date': dateController.text.trim(),
                  'driver_name': driverController.text.trim(),
                  'items': itemsController.text
                      .split(',')
                      .map((item) => item.trim())
                      .toList(),
                  'status': statusController.text.trim().toLowerCase() == 'true',
                };

                await storeDataInDatabase(updatedData);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
  void _showRecognizedText(String text) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recognized Text'),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _model.dispose();
    super.dispose();
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
              context.pushNamed('Landing');
            },
          ),
          title: Text(
            'Camera',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Work Sans',
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Expanded(
                child: _isCameraInitialized && _cameraController != null
                    ? CameraPreview(_cameraController!)
                    : const Center(child: CircularProgressIndicator()),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _captureAndRecognizeText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                  ),
                  child: const Text(
                    'Capture and Recognize Text',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
