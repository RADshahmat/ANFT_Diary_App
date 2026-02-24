import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

void viewDataDetail(BuildContext ctx, String batch, String jsonData) {
  Navigator.of(ctx).push(
    MaterialPageRoute(
      builder: (_) {
        return DataDetailPage(batch: batch, jsonData: jsonData);
      },
    ),
  );
}

class DataDetailPage extends StatelessWidget {
  final String batch;
  final String jsonData;

  DataDetailPage({
    required this.batch,
    required this.jsonData,
  });

  @override
  Widget build(BuildContext context) {
    List<dynamic> jsonDataList = jsonDecode(jsonData);
    List<String> individualValues = [];
    List<String> individualId = [];
    List<String> individualnumber = [];
    List<String> individualdesignation = [];
    List<String> individualwork = [];
    List<String> individualemail = [];
    List<String> permanentAddress = [];

    for (var data in jsonDataList) {
      if (data['Batch'] == batch) {
        individualValues.add(data['Name'].toString());
        individualId.add(data['RollNo'].toString());
        individualnumber.add(data['PhoneNumber'].toString());
        individualdesignation.add(data['Designation'].toString());
        individualwork.add(data['CurrentWorkplace'].toString());
        individualemail.add(data['Email'].toString());
        permanentAddress.add(data['PermanentAddress']);
      }
    }

    individualValues[0] = individualValues[0].replaceAll('[', '');
    individualValues[individualValues.length - 1] =
        individualValues[individualValues.length - 1].replaceAll(']', '');

    individualId[0] = individualId[0].replaceAll('[', '');
    individualId[individualId.length - 1] =
        individualId[individualId.length - 1].replaceAll(']', '');

    individualnumber[0] = individualnumber[0].replaceAll('[', '');
    individualnumber[individualnumber.length - 1] =
        individualnumber[individualnumber.length - 1].replaceAll(']', '');

    individualdesignation[0] = individualdesignation[0].replaceAll('[', '');
    individualdesignation[individualdesignation.length - 1] =
        individualdesignation[individualdesignation.length - 1]
            .replaceAll(']', '');

    individualwork[0] = individualwork[0].replaceAll('[', '');
    individualwork[individualwork.length - 1] =
        individualwork[individualwork.length - 1].replaceAll(']', '');

    individualemail[0] = individualemail[0].replaceAll('[', '');
    individualemail[individualemail.length - 1] =
        individualemail[individualemail.length - 1].replaceAll(']', '');

    permanentAddress[0] = permanentAddress[0].replaceAll('[', '');
    permanentAddress[permanentAddress.length - 1] =
        permanentAddress[permanentAddress.length - 1].replaceAll(']', '');

    return Scaffold(
      appBar: AppBar(
        title: Text(batch + ' Batch'),
      ),
      body: ListView.builder(
        itemCount: individualValues.length,
        itemBuilder: (ctx, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => IndividualDetailPage(
                    name: individualValues[index],
                    phoneNumber: individualnumber[index],
                    designation: individualdesignation[index],
                    workingPlace: individualwork[index],
                    address: permanentAddress[index],
                    value: individualwork[index],
                    email: individualemail[index],
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 2),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                elevation: 6,
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.account_circle,
                              size: 41.0,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 250,
                                child: Text(
                                  individualValues[index],
                                  style: const TextStyle(fontSize: 22),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                individualId[index],
                                style: const TextStyle(fontSize: 17),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class IndividualDetailPage extends StatelessWidget {
  final String name;
  final String phoneNumber;
  final String designation;
  final String workingPlace;
  final String value;
  final String address;
  final String email;

  IndividualDetailPage({
    required this.name,
    required this.phoneNumber,
    required this.designation,
    required this.workingPlace,
    required this.address,
    required this.value,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, right: 15, left: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        backgroundColor: Colors.teal,
                        radius: 35,
                        child: Icon(
                          Icons.account_circle,
                          color: Colors.white,
                          size: 65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Center(
                      child: Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      child: const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Phone No',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        phoneNumber,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      child: const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Designation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        designation,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      child: const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Working Place',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        workingPlace,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      child: const Divider(
                        color: Colors.grey,
                        thickness: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Address',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (phoneNumber != 'N/A' && phoneNumber != 'na') ...[
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.call),
                                onPressed: () {
                                  _launchCall(phoneNumber);
                                },
                              ),
                              const Text('Call'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  _launchMessage(phoneNumber);
                                },
                              ),
                              const Text('Message'),
                            ],
                          ),
                        ] else ...[
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.call),
                                onPressed: () {
                                  _showNoPhoneNumberDialog(context);
                                },
                              ),
                              const Text('Call'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.message),
                                onPressed: () {
                                  _showNoPhoneNumberDialog(context);
                                },
                              ),
                              const Text('Message'),
                            ],
                          ),
                        ],
                        Column(
                          children: [
                            if (email != 'N/A' && email != 'na') ...[
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.email),
                                    onPressed: () async {
                                      final url = 'mailto:$email';
                                      if (await canLaunch(url)) {
                                        await launch(url);
                                      } else {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                                  const Text('Mail'),
                                ],
                              ),
                            ] else ...[
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.email),
                                    onPressed: () {
                                      _showNoEmailDialog(context);
                                    },
                                  ),
                                  const Text('Mail'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30, right: 15, left: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () {
                              _showQRCode(context, name, phoneNumber, email);
                            },
                          ),
                          const Text('QR Code'),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              _showCopyOptions(context, phoneNumber, email);
                            },
                          ),
                          const Text('Copy'),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _launchCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {}
  }

  void _launchMessage(String phoneNumber) async {
    final url = 'sms:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {}
  }

  void _showNoPhoneNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Phone Number'),
          content: const Text(
              'There is no phone number associated with this contact.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showNoEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Email Account'),
          content: const Text(
              'There is no Email Account associated with this contact.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showQRCode(
      BuildContext context, String name, String phoneNumber, String email) {
    final data = 'Name: $name\nPhone: $phoneNumber\nEmail: $email';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200.0,
                height: 200.0,
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                ),
              ),
              const SizedBox(height: 20),
              const Text('Scan this QR code for more info.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showCopyOptions(
      BuildContext context, String phoneNumber, String email) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: Colors.white,
              leading: const Icon(
                Icons.phone,
                color: Colors.black,
              ),
              title: const Text(
                'Copy Phone Number',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: phoneNumber));
                Navigator.of(context).pop();
                _showSnackBar(context, 'Phone number copied');
              },
            ),
            ListTile(
              tileColor: Colors.white,
              leading: const Icon(
                Icons.email,
                color: Colors.black,
              ),
              title: const Text(
                'Copy Email',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: email));
                Navigator.of(context).pop();
                _showSnackBar(context, 'Email copied');
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
