import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:wise/screens/user/addTransaction/reviewTransaction.dart';

class ScanReceiptPage extends StatefulWidget {
  @override
  _ScanReceiptPageState createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Camera permission is required to scan receipts.")),
      );
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      setState(() {});
    } else {
      print('No cameras available');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final XFile picture = await _cameraController!.takePicture();
        _processImage(picture.path);
      } catch (e) {
        print("Error capturing image: $e");
      }
    } else {
      print("Camera is not initialized");
    }
  }

  Future<void> _uploadImageFromDevice() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _processImage(image.path);
    }
  }

  Future<void> _processImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    // Print the entire recognized text for debugging
    print("Recognized Text: ${recognizedText.text}");

    bool isValidReceipt = _containsReceiptKeyword(recognizedText.text);

    if (isValidReceipt) {
      final String transactionTime =
          _extractTransactionTime(recognizedText.text);
      final String transactionDate =
          _extractTransactionDate(recognizedText.text);
      final String amount = _extractAmount(recognizedText.text);
      final String description = _extractDescription(recognizedText.text);

      _navigateToReviewPage(
        transactionTime,
        transactionDate,
        amount,
        description,
      );
    } else {
      _showInvalidReceiptMessage();
    }
  }

  bool _containsReceiptKeyword(String detectedText) {
    return detectedText.contains(RegExp(
        r"\b(receipt|Receipt|RECEIPT|invoice|total|Total|subtotal|Subtotal|amount|Amount|purchase|Purchase)\b"));
  }

  void _showInvalidReceiptMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Invalid Receipt"),
          content: Text(
              "The captured image does not appear to be a valid receipt. Please try again."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToReviewPage(String transactionTime, String transactionDate,
      String amount, String description) {
    try {
      // Parse date and time separately
      DateTime parsedDate = DateFormat('MM/dd/yyyy')
          .parse(transactionDate); // Change this to match your expected format
      DateTime parsedTime = DateFormat('hh:mm a').parse(transactionTime);

      // Combine date and time into a single DateTime object
      DateTime transactionDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewTransactionPage(
            amount: amount,
            description: description,
            transactionDateTime:
                transactionDateTime, // Pass the DateTime object here
          ),
        ),
      );
    } catch (e) {
      print("Error parsing date/time: $e");
      // Fallback to current date and time if parsing fails
      DateTime now = DateTime.now();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewTransactionPage(
            amount: amount,
            description: description,
            transactionDateTime: now, // Use current date/time
          ),
        ),
      );
    }
  }

  String _extractTransactionTime(String text) {
    final timePattern = RegExp(r'(\b\d{1,2}:\d{2}\s?(AM|PM|am|pm)\b)');
    final match = timePattern.firstMatch(text);

    if (match != null) {
      return match.group(0) ?? "Time not found";
    } else {
      // Using current time and notifying the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Using current time for the transaction.")),
      );
      return DateFormat('hh:mm a').format(DateTime.now());
    }
  }

  String _extractTransactionDate(String text) {
    final datePatterns = [
      RegExp(r'\b\d{1,2}/\d{1,2}/\d{2,4}\b'),
      RegExp(r'\b\d{1,2}-\d{1,2}-\d{2,4}\b'),
      RegExp(r'\b\d{1,2}\s\w+\s\d{2,4}\b'),
      RegExp(r'\b\w+\s\d{1,2},\s\d{4}\b'),
    ];

    for (var pattern in datePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0) ?? "Date not found";
      }
    }

    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String _extractAmount(String text) {
    // Regular expression to capture amounts after "total", "amount due", etc.
    final RegExp labeledTotalPattern = RegExp(
      r"(total\s*amount|total|amount due|subtotal)[\s:]*\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)",
      caseSensitive: false,
    );

    // Match all labeled amounts
    final labeledMatches = labeledTotalPattern.allMatches(text);

    // If we find labeled totals, take the last one (likely the final total)
    if (labeledMatches.isNotEmpty) {
      return labeledMatches.last.group(2) ?? "0.00";
    }

    // Fallback: Extract all standalone monetary amounts (unlabeled)
    final RegExp standaloneAmountPattern = RegExp(
      r"\$?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)",
    );
    final standaloneMatches = standaloneAmountPattern.allMatches(text);

    // Find the largest amount as a fallback
    double maxAmount = 0.0;
    for (final match in standaloneMatches) {
      final amountString = match.group(1) ?? "0.00";
      final amount = double.tryParse(amountString.replaceAll(',', '')) ?? 0.0;
      if (amount > maxAmount) {
        maxAmount = amount;
      }
    }

    return maxAmount > 0 ? maxAmount.toStringAsFixed(2) : "0.00";
  }

  String _extractDescription(String text) {
    // Exclude lines that match common keywords such as "TOTAL", "CASH", "CHANGE"
    final RegExp excludeKeywordsPattern = RegExp(
      r"\b(total amount|total|amount due|subtotal|cash|change|thank you|receipt)\b",
      caseSensitive: false,
    );

    // Split text into lines for easier processing
    List<String> lines = text.split('\n');

    // Filter out lines that contain keywords and are not item descriptions
    List<String> descriptionLines = lines.where((line) {
      return !excludeKeywordsPattern.hasMatch(line) && line.trim().isNotEmpty;
    }).toList();

    // Combine lines into a single description string
    // You could limit the number of lines here if needed
    String description = descriptionLines.join(', ');

    return description.isNotEmpty ? description : "No description available";
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Column(
        children: [
          SizedBox(height: 10.0),
          AppBar(
            backgroundColor: Color(0xFF1E1E1E),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Scan Receipt',
              style: TextStyle(
                color: Color(0xFFF8E4B2),
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(width: 2.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  _cameraController != null &&
                          _cameraController!.value.isInitialized
                      ? SizedBox.expand(
                          child: CameraPreview(_cameraController!))
                      : Center(child: CircularProgressIndicator()),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: IconButton(
                      icon:
                          Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      onPressed: _captureImage,
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.upload_file,
                          color: Colors.white, size: 32),
                      onPressed: _uploadImageFromDevice,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Align items to the top
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8.0), // Space between icon and text
                  Expanded(
                    child: Text(
                      "The image captured is not 100 percent precise. "
                      "To avoid misreading, ensure that you hold and scan the receipt properly. "
                      "You can edit them later.",
                      style: TextStyle(
                        color: Color(0xFFF8E4B2),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
