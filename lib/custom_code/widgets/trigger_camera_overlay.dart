import 'package:flutter/material.dart';
import 'package:flutter_camera_overlay/model.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TriggerCameraOverlay extends StatefulWidget {
  const TriggerCameraOverlay({
    super.key,
    this.width,
    this.height,
    this.cardType,
    this.infoText,
    this.labelText,
    this.buttonText,
    this.buttonColor,
    this.onCapture,
    this.borderRadius,
    this.padding,
    this.rotateCamera,
  });

  final double? width;
  final double? height;
  final int? cardType;
  final String? infoText;
  final String? labelText;
  final String? buttonText;
  final Color? buttonColor;
  final Future Function(String recognizedText)? onCapture;
  final double? borderRadius;
  final double? padding;
  final bool? rotateCamera;

  @override
  State<TriggerCameraOverlay> createState() => _TriggerCameraOverlayState();
}

class _TriggerCameraOverlayState extends State<TriggerCameraOverlay> {
  late OverlayFormat format;

  @override
  void initState() {
    super.initState();
    _setFormat();
  }

  void _setFormat() {
    switch (widget.cardType) {
      case 1:
        format = OverlayFormat.cardID3;
        break;
      case 2:
        format = OverlayFormat.simID000;
        break;
      case 0:
      default:
        format = OverlayFormat.cardID1;
    }
  }

  Future<void> _launchCameraOverlay() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera found')),
      );
      return;
    }

    if (widget.rotateCamera ?? false) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    final XFile? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraOverlay(
          cameras.first,
          CardOverlay.byFormat(format),
          (XFile file) {
            Navigator.pop(context, file);
          },
          info: widget.infoText ?? '',
          label: widget.labelText ?? 'Position ID card within rectangle.',
        ),
      ),
    );

    if (widget.rotateCamera ?? false) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    if (result != null) {
      await _processTextRecognition(result);
    } else {
      if (widget.onCapture != null) {
        widget.onCapture!('');
      }
    }
  }

  Future<void> _processTextRecognition(XFile result) async {
    try {
      final inputImage = InputImage.fromFilePath(result.path);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Close the text recognizer after use
      textRecognizer.close();

      // Extract the recognized text
      String extractedText = recognizedText.text;

      if (widget.onCapture != null) {
        widget.onCapture!(extractedText); // return recognized text
      }
    } catch (e) {
      print('Error during text recognition: $e');
      if (widget.onCapture != null) {
        widget.onCapture!('');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _launchCameraOverlay,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.buttonColor ?? Theme.of(context).primaryColor,
        minimumSize: Size(widget.width ?? double.infinity, widget.height ?? 50.0),
        padding: EdgeInsets.all(widget.padding ?? 8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8.0),
        ),
      ),
      child: Text(widget.buttonText ?? 'Launch Camera'),
    );
  }
}
