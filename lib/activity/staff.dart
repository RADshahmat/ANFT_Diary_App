import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(

        hintColor: Colors.purpleAccent,
        fontFamily: 'Roboto',
      ),
      home: staff(),
    );
  }
}

class staff extends StatefulWidget {
  @override
  _TeachersState createState() => _TeachersState();
}

class _TeachersState extends State<staff> {
  final List<String> _dataList3 = [];
  final List<String> _designationList1 = [];
  final List<String> _phoneList1 = [];
  final List<String> _emailList1 = [];
  final List<String> _imageAddressList1 = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _checkInternetConnectivity();
  }

  Future<void> _checkInternetConnectivity2() async {
    final url = Uri.parse('https://www.google.com');
    final client = http.Client();

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        print('Connected to the internet');
        getData();
      } else {
        print('Not connected to the internet');
      }
    } on SocketException catch (_) {
      print('Not connected to the internet');
    } finally {
      client.close();
    }
  }

  Future<void> _checkInternetConnectivity() async {
    final url = Uri.parse('https://www.google.com');
    final client = http.Client();

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        print('Connected to the internet');
        final isFirstRun = await _isFirstRun();
        if (isFirstRun) {
          getData();

          await _setFirstRunFlag(false);
        } else {
          final lastFetchDate = await _getLastFetchDate();
          final currentDate = DateTime.now();
          if (lastFetchDate == null ||
              currentDate.difference(lastFetchDate).inDays >= 30 ||
              _dataList3.isEmpty) {
            getData();

            await _setLastFetchDate(currentDate);
          }
        }
      } else {
        print('Not connected to the internet');
      }
    } on SocketException catch (_) {
      print('Not connected to the internet');
    } finally {
      client.close();
    }
  }

  Future<bool> _isFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstRun2') ?? true;
  }

  Future<void> _setFirstRunFlag(bool isFirstRun) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun2', isFirstRun);
  }

  Future<DateTime?> _getLastFetchDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getString('lastFetchTimestamp2');
    if (lastFetchTimestamp != null) {
      return DateTime.parse(lastFetchTimestamp);
    }
    return null;
  }

  Future<void> _setLastFetchDate(DateTime dateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFetchTimestamp2', dateTime.toIso8601String());
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDataList = prefs.getStringList('dataList3') ?? [];
    List<String> savedDesignationList =
        prefs.getStringList('designationList1') ?? [];
    List<String> savedPhoneList = prefs.getStringList('phoneList1') ?? [];
    List<String> savedEmailList = prefs.getStringList('emailList1') ?? [];
    List<String> savedImageAddressList =
        prefs.getStringList('imageAddressList1') ?? [];

    setState(() {
      _dataList3.clear();
      _designationList1.clear();
      _phoneList1.clear();
      _emailList1.clear();
      _imageAddressList1.clear();

      _dataList3.addAll(savedDataList);
      _designationList1.addAll(savedDesignationList);
      _phoneList1.addAll(savedPhoneList);
      _emailList1.addAll(savedEmailList);
      _imageAddressList1.addAll(savedImageAddressList);
    });
  }

  void _viewDataDetail(BuildContext ctx, String data, String designation) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.only(top: 75, right: 15, left: 15),
                    elevation: 4,
                    color: Colors.white,
                    shadowColor: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 25.0,
                        bottom: 25,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.account_circle_sharp,
                              color: Colors.white,
                              size: 70,
                            ),
                            radius: 40,
                          ),
                          SizedBox(height: 30),
                          Text(
                            '$data',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '$designation',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '${_phoneList1[_dataList3.indexOf(data)] != 'N/A' ? _phoneList1[_dataList3.indexOf(data)] : 'N/A'}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '${_emailList1[_dataList3.indexOf(data)] != 'N/A' ? _emailList1[_dataList3.indexOf(data)] : 'N/A'}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 35),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (_phoneList1[_dataList3.indexOf(data)] !=
                                          'N/A' &&
                                      _phoneList1[_dataList3.indexOf(data)] !=
                                          'na' &&
                                      _phoneList1[_dataList3.indexOf(data)] !=
                                          'NA' &&
                                      _phoneList1[_dataList3.indexOf(data)] !=
                                          'n/a') {
                                    _launchCall(
                                        _phoneList1[_dataList3.indexOf(data)]);
                                  } else {
                                    _showNoPhoneNumberDialog(context);
                                  }
                                },
                                icon: Icon(Icons.call),
                                label: Text('Call'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_phoneList1[_dataList3.indexOf(data)] !=
                                          'N/A' &&
                                      _phoneList1[_dataList3.indexOf(data)] !=
                                          'na' &&
                                      _phoneList1[_dataList3.indexOf(data)] !=
                                          'NA' &&
                                      _phoneList1[_dataList3.indexOf(data)] !=
                                          'n/a') {
                                    _launchMessage(
                                        _phoneList1[_dataList3.indexOf(data)]);
                                  } else {
                                    _showNoPhoneNumberDialog(context);
                                  }
                                },
                                icon: Icon(Icons.message),
                                label: Text('Message'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_emailList1[_dataList3.indexOf(data)] !=
                                          'N/A' &&
                                      _emailList1[_dataList3.indexOf(data)] !=
                                          'na' &&
                                      _emailList1[_dataList3.indexOf(data)] !=
                                          'NA' &&
                                      _emailList1[_dataList3.indexOf(data)] !=
                                          'n/a') {
                                    _launchEmail(
                                        _emailList1[_dataList3.indexOf(data)]);
                                  } else {
                                    _showNoEmail(context);
                                  }
                                },
                                icon: Icon(Icons.email),
                                label: Text('Email'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchMessage(String phoneNumber) async {
    final url = 'sms:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

  void _showNoEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Email'),
          content:
              const Text('There is no Email associated with this contact.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Office Staff',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _checkInternetConnectivity2();
        },
        child: ListView.builder(
          itemCount: _dataList3.length,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                _viewDataDetail(
                    context, _dataList3[index], _designationList1[index]);
              },
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.teal,
                      size: 40,
                    ),
                  ),
                  title: Text(
                    _dataList3[index],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    _designationList1[index],
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color.fromARGB(221, 75, 72, 72),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future getData() async {
    var url = '${baseUrl}get3.php';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    try {
      http.Response response = await http.get(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token', // Send token in header
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        List<String> extractedNames = [];
        List<String> extractedDesignations = [];
        List<String> extractedPhones = [];
        List<String> extractedEmails = [];
        List<String> extractedImageAddresses = [];

        for (var item in data) {
          if (item.containsKey('StaffName')) {
            extractedNames.add(item['StaffName']);
          }
          if (item.containsKey('Designation')) {
            extractedDesignations.add(item['Designation']);
          }
          if (item.containsKey('PhoneNo')) {
            extractedPhones.add(item['PhoneNo']);
          }
          if (item.containsKey('Email')) {
            extractedEmails.add(item['Email']);
          }
          if (item.containsKey('ImageAddress')) {
            extractedImageAddresses.add(item['ImageAddress']);
          }
        }
        if (!mounted) return;
        setState(() {
          _dataList3.clear();
          _designationList1.clear();
          _phoneList1.clear();
          _emailList1.clear();
          _imageAddressList1.clear();

          _dataList3.addAll(extractedNames);
          _designationList1.addAll(extractedDesignations);
          _phoneList1.addAll(extractedPhones);
          _emailList1.addAll(extractedEmails);
          _imageAddressList1.addAll(extractedImageAddresses);

          _saveDataToLocal(
            extractedNames,
            extractedDesignations,
            extractedPhones,
            extractedEmails,
            extractedImageAddresses,
          );
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _saveDataToLocal(
    List<String> names,
    List<String> designations,
    List<String> phones,
    List<String> emails,
    List<String> imageAddresses,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dataList3', names);
    await prefs.setStringList('designationList1', designations);
    await prefs.setStringList('phoneList1', phones);
    await prefs.setStringList('emailList1', emails);
    await prefs.setStringList('imageAddressList1', imageAddresses);
  }
}
