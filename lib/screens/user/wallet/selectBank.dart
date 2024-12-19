import 'package:flutter/material.dart';
import 'package:wise/screens/user/components/navBar.dart';
import 'package:wise/screens/user/wallet/connecting.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BankSelectionPage extends StatefulWidget {
  @override
  _BankSelectionPageState createState() => _BankSelectionPageState();
}

class _BankSelectionPageState extends State<BankSelectionPage> {
  List<Map<String, dynamic>> bankList = [];
  String? selectedBank; // To keep track of the selected bank
  bool isLoading = true; // New variable to track loading state

  @override
  void initState() {
    super.initState();
    _loadBankImages();
  }

  Future<void> _loadBankImages() async {
    final storageRef = FirebaseStorage.instance.ref().child('banks');
    final ListResult result = await storageRef.listAll();

    List<Map<String, dynamic>> loadedBankList = [];

    // Iterate over each folder inside the 'banks' directory
    for (var folderRef in result.prefixes) {
      // List all items inside each subfolder
      final ListResult subfolderResult = await folderRef.listAll();

      for (var fileRef in subfolderResult.items) {
        // Get the download URL of each image
        final url = await fileRef.getDownloadURL();
        String name = fileRef.name;
        name = name
            .replaceAll('_', ' ')
            .replaceAll('Bank', '')
            .replaceAll('.jpg', '')
            .replaceAll('.png',
                ''); // Adjust if there are PNG files or other extensions

        loadedBankList.add({
          'name': name.trim(),
          'url': url,
        });
      }
    }

    setState(() {
      bankList = loadedBankList;
      isLoading = false; // Stop showing the loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF1E1E1E),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo/logoWithPadding.png',
                width: 80,
                height: 80,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Connect To Bank Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF333333),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Bank',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFF8E4B2), // Customize color
                              ),
                            )
                          : ListView.builder(
                              itemCount: bankList.length,
                              itemBuilder: (context, index) {
                                final bank = bankList[index];
                                return BankOption(
                                  imagePath: bank['url'],
                                  bankName: bank['name'],
                                  isSelected: selectedBank == bank['name'],
                                  onTap: () {
                                    setState(() {
                                      selectedBank = bank['name'];
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFF8E4B2),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: () {
                          if (selectedBank != null) {
                            // Fetch the selected bank's logo URL
                            final selectedBankLogoUrl = bankList.firstWhere(
                              (bank) => bank['name'] == selectedBank,
                              orElse: () => {'url': ''},
                            )['url'];

                            // Proceed to the ConnectingPage with selected bank information
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ConnectingPage(
                                  bankLogoPath: selectedBankLogoUrl,
                                  bankName: selectedBank!,
                                ),
                              ),
                            );
                          } else {
                            // Show an alert if no bank is selected
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: Color(
                                          0xFF1E1E1E), // Dark background color
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blueAccent,
                                          size: 60,
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'No Bank Selected',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Please select a bank before continuing.',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blueAccent,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class BankOption extends StatelessWidget {
  final String imagePath;
  final String bankName;
  final bool isSelected;
  final VoidCallback onTap;

  const BankOption({
    required this.imagePath,
    required this.bankName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: isSelected ? 3.0 : 1.0,
            ),
          ),
        ),
        onPressed: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16.0),
          ),
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.network(
                imagePath,
                width: 40,
                height: 40,
              ),
              SizedBox(width: 16),
              Text(
                bankName,
                style: TextStyle(
                  color: isSelected ? Color(0xFFF8E4B2) : Colors.white,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
