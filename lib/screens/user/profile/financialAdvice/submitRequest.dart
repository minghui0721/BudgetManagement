import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wise/models/FinancialAdvisor.dart';
import 'package:wise/providers/FinancialAdvisorProvider.dart';
import 'package:wise/providers/userGlobalVariables.dart';
import 'package:wise/screens/user/profile/financialAdvice/pendingFinancialAdvice.dart';

class SubmitRequestToAdvisorPage extends StatefulWidget {
  final FinancialAdvisor advisor;

  SubmitRequestToAdvisorPage({required this.advisor});

  @override
  _SubmitRequestToAdvisorPageState createState() =>
      _SubmitRequestToAdvisorPageState();
}

class _SubmitRequestToAdvisorPageState
    extends State<SubmitRequestToAdvisorPage> {
  final TextEditingController _messageController = TextEditingController();
  bool isSubmitting = false;
  String? qrCodeUrl;

  @override
  void initState() {
    super.initState();
    fetchQRCodeUrl();
  }

  Future<void> fetchQRCodeUrl() async {
    try {
      final ref =
          FirebaseStorage.instance.ref().child('financialAdvisor/qrCode.png');
      String url = await ref.getDownloadURL();
      setState(() {
        qrCodeUrl = url;
      });
    } catch (e) {
      print("Error fetching QR code URL: $e");
    }
  }

  Future<void> launchLinkedInProfile() async {
    final Uri url =
        Uri.parse("https://www.linkedin.com/in/ming-hui-8311bb293/");
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> submitRequest() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final requestRef = FirebaseFirestore.instance
          .collection('FinancialAdvisors')
          .doc(widget.advisor.id)
          .collection('Request')
          .doc();

      await requestRef.set({
        'Status': 'Pending',
        'additionalComment': _messageController.text,
        'submitRequestTime': FieldValue.serverTimestamp(),
        'timeRespond': FieldValue.serverTimestamp(),
        'userID': FirebaseFirestore.instance
            .collection('Users')
            .doc(UserData().uid), // Use the DocumentReference here
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request sent to ${widget.advisor.user.name}"),
          backgroundColor: Colors.blue,
        ),
      );

      _messageController.clear();

      // Navigate to the PendingPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PendingPage(advisorName: widget.advisor.user.name),
        ),
      );
    } catch (e) {
      print("Error submitting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send request"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Submission"),
          content: Text("Are you sure you want to submit this request?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );

    if (shouldSubmit == true) {
      submitRequest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final advisor = widget.advisor;

    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Column(
        children: [
          SizedBox(height: 15),
          AppBar(
            title: Text(
              "Request",
              style: TextStyle(
                color: Color(0xFFF8E4B2),
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Color(0xFF1E1E1E),
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF474747),
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8)),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Advisor Card",
                              style: TextStyle(
                                color: Color(0xFFF8E4B2),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: Color(0xFFF8E4B2),
                                child: Icon(
                                  Icons.account_circle,
                                  color: Color(0xFF1E1E1E),
                                  size: 50,
                                ),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name: ${advisor.user.name}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Occupation: ${advisor.user.occupation}",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Verified: ${advisor.isVerified ? "Yes" : "No"}",
                                    style: TextStyle(
                                      color: advisor.isVerified
                                          ? Color(0xFF6BF178)
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Divider(color: Colors.black26),
                          SizedBox(height: 10),
                          Center(
                            child: GestureDetector(
                              onTap: launchLinkedInProfile,
                              child: qrCodeUrl != null
                                  ? Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Image.network(
                                        qrCodeUrl!,
                                        width: 100,
                                        height: 100,
                                      ),
                                    )
                                  : CircularProgressIndicator(
                                      color: Color(0xFFF8E4B2)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Divider(color: Colors.grey, thickness: 1),
                    SizedBox(height: 30),
                    Text(
                      "Message to Advisor",
                      style: TextStyle(
                        color: Color(0xFFF8E4B2),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _messageController,
                      maxLines: 4,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add a message (optional)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Color(0xFF2C2C2C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      ),
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: isSubmitting
                          ? CircularProgressIndicator(color: Color(0xFFF8E4B2))
                          : ElevatedButton(
                              onPressed: _showConfirmationDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF8E4B2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 40),
                                shadowColor: Color(0xFF000000).withOpacity(0.2),
                                elevation: 10,
                              ),
                              child: Text(
                                "Submit Request",
                                style: TextStyle(
                                  color: Color(0xFF1E1E1E),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
