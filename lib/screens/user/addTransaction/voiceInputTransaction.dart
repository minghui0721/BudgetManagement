import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:wise/screens/user/addTransaction/reviewTransaction.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceInputTransactionPage extends StatefulWidget {
  @override
  _VoiceInputTransactionPageState createState() =>
      _VoiceInputTransactionPageState();
}

class _VoiceInputTransactionPageState extends State<VoiceInputTransactionPage> {
  DateTime transactionDateTime = DateTime.now();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInputText = "";
  double _accuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkMicrophonePermission();
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == "listening") {
          setState(() {
            _isListening = true;
          });
        } else {
          setState(() {
            _isListening = false;
          });
        }
      },
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _voiceInputText = val.recognizedWords;
          _accuracy = val.confidence * 100;
        }),
      );
    } else {
      print("Speech recognition is not available.");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _submitVoiceInput() {
    _stopListening();
    if (_voiceInputText.isNotEmpty) {
      _processVoiceInput(_voiceInputText);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please say something to add."),
        ),
      );
    }
  }

  void _processVoiceInput(String input) {
    // Use a regular expression to find the first number in the input
    RegExp regex = RegExp(r'\b\d+(\.\d{1,2})?\b');
    Match? match = regex.firstMatch(input);

    String amount = match != null
        ? match.group(0)!
        : "0"; // Use the matched number or set default to "0"
    String description = input;

    // Navigate to ReviewTransactionPage with extracted details
    _navigateToReviewPage(amount, description, transactionDateTime);
  }

  void _navigateToReviewPage(
      String amount, String description, DateTime transactionDateTime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewTransactionPage(
          amount: amount,
          description: description,
          transactionDateTime: transactionDateTime,
        ),
      ),
    );
  }

  AppBar buildCustomAppBar(String title) {
    return AppBar(
      backgroundColor: Color(0xFF1E1E1E),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFFF8E4B2),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 15.0), // 15-pixel space above the AppBar
            buildCustomAppBar('Voice Input'), // AppBar at the top
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Transcribed Text Display
                        Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            _voiceInputText.isEmpty
                                ? "Your voice input will appear here..."
                                : _voiceInputText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 50.0),

                        // Microphone Button
                        Center(
                          child: GestureDetector(
                            onTap:
                                _isListening ? _stopListening : _startListening,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: _isListening ? Colors.red : Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  if (_isListening)
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.5),
                                      spreadRadius: 10,
                                      blurRadius: 20,
                                    ),
                                ],
                              ),
                              child: Icon(
                                _isListening ? Icons.mic_off : Icons.mic,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        if (_isListening)
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              "Listening... Speak now!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        SizedBox(
                            height:
                                50.0), // Space between microphone and buttons

                        // Done and Cancel Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: _submitVoiceInput,
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.0, vertical: 14.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                50.0), // Space between buttons and info section

                        // Info Section
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(
                                    width: 8.0), // Space between icon and text
                                Expanded(
                                  child: Text(
                                    "Voice input accuracy may not be 100% precise. "
                                    "To improve recognition, speak clearly and avoid background noise.",
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
