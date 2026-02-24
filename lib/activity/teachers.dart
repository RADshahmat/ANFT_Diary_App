import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo, // General theme color
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo, // AppBar background color
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // AppBar title color
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // AppBar icons color
          ),
        ),
      ),
      home: const Teachers(),
    );
  }
}

class Teachers extends StatefulWidget {
  const Teachers({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TeachersState createState() => _TeachersState();
}

class _TeachersState extends State<Teachers> {
  final List<String> _dataList2 = [];
  final List<String> _designationList = [];
  final List<String> _phoneList = [];
  final List<String> _emailList = [];
  final List<String> _imageAddressList = [];

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
              _dataList2.isEmpty) {
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
    return prefs.getBool('isFirstRun1') ?? true;
  }

  Future<void> _setFirstRunFlag(bool isFirstRun) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun1', isFirstRun);
  }

  Future<DateTime?> _getLastFetchDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getString('lastFetchTimestamp1');
    if (lastFetchTimestamp != null) {
      return DateTime.parse(lastFetchTimestamp);
    }
    return null;
  }

  Future<void> _setLastFetchDate(DateTime dateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFetchTimestamp1', dateTime.toIso8601String());
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDataList = prefs.getStringList('dataList2') ?? [];
    List<String> savedDesignationList =
        prefs.getStringList('designationList') ?? [];
    List<String> savedPhoneList = prefs.getStringList('phoneList') ?? [];
    List<String> savedEmailList = prefs.getStringList('emailList') ?? [];
    List<String> savedImageAddressList =
        prefs.getStringList('imageAddressList') ?? [];

    setState(() {
      _dataList2.clear();
      _designationList.clear();
      _phoneList.clear();
      _emailList.clear();
      _imageAddressList.clear();

      _dataList2.addAll(savedDataList);
      _designationList.addAll(savedDesignationList);
      _phoneList.addAll(savedPhoneList);
      _emailList.addAll(savedEmailList);
      _imageAddressList.addAll(savedImageAddressList);
    });
  }

  void _viewDataDetail(BuildContext ctx, String data, String designation) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
              appBar: AppBar(
                title: const Text(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Card(
                        margin:
                            const EdgeInsets.only(top: 75, right: 15, left: 15),
                        elevation: 5,
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
                                backgroundImage: NetworkImage(_imageAddressList[
                                    _dataList2.indexOf(data)]),
                                radius: 60,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                '$data',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$designation',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _phoneList[_dataList2.indexOf(data)] != 'N/A'
                                    ? _phoneList[_dataList2.indexOf(data)]
                                    : 'Not available',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _emailList[_dataList2.indexOf(data)] != 'N/A'
                                    ? _emailList[_dataList2.indexOf(data)]
                                    : 'Not available',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      if (_phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'N/A' &&
                                          _phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'na' &&
                                          _phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'NA' &&
                                          _phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'n/a') {
                                        final Uri url = Uri(
                                          scheme: 'tel',
                                          path: _phoneList[
                                              _dataList2.indexOf(data)],
                                        );
                                        if (await canLaunchUrl(url)) {
                                          await launchUrl(url);
                                        } else {
                                          throw 'Could not launch $url';
                                        }
                                      } else {
                                        _showNoPhoneNumberDialog(context);
                                      }
                                    },
                                    icon: const Icon(Icons.call),
                                    label: const Text('Call'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      elevation: 5,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (_phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'N/A' &&
                                          _phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'na' &&
                                          _phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'NA' &&
                                          _phoneList[
                                                  _dataList2.indexOf(data)] !=
                                              'n/a') {
                                        _launchMessage(_phoneList[
                                            _dataList2.indexOf(data)]);
                                      } else {
                                        _showNoPhoneNumberDialog(context);
                                      }
                                    },
                                    icon: const Icon(Icons.message),
                                    label: const Text('Message'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      elevation: 5,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      if (_emailList[
                                                  _dataList2.indexOf(data)] !=
                                              'N/A' &&
                                          _emailList[
                                                  _dataList2.indexOf(data)] !=
                                              'na' &&
                                          _emailList[
                                                  _dataList2.indexOf(data)] !=
                                              'NA' &&
                                          _emailList[
                                                  _dataList2.indexOf(data)] !=
                                              'n/a') {
                                        _launchEmail(_emailList[
                                            _dataList2.indexOf(data)]);
                                      } else {
                                        _showNoEmail(context);
                                      }
                                    },
                                    icon: const Icon(Icons.email),
                                    label: const Text('Email'),
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
                    ),
                  ],
                ),
              ));
        },
      ),
    );
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
        title: const Text(
          'Teachers',
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
          itemCount: _dataList2.length,
          itemBuilder: (ctx, index) {
            return GestureDetector(
              onTap: () {
                _viewDataDetail(
                    context, _dataList2[index], _designationList[index]);
              },
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(_imageAddressList[index]),
                  ),
                  title: Text(
                    _dataList2[index],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    _designationList[index],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(221, 75, 72, 72),
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
    var url = '${baseUrl}get2.php';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token'); // Retrieve token from SharedPreferences

    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token',
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
          if (item.containsKey('TeacherName')) {
            extractedNames.add(item['TeacherName']);
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
          _dataList2.clear();
          _designationList.clear();
          _phoneList.clear();
          _emailList.clear();
          _imageAddressList.clear();

          _dataList2.addAll(extractedNames);
          _designationList.addAll(extractedDesignations);
          _phoneList.addAll(extractedPhones);
          _emailList.addAll(extractedEmails);
          _imageAddressList.addAll(extractedImageAddresses);

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
    await prefs.setStringList('dataList2', names);
    await prefs.setStringList('designationList', designations);
    await prefs.setStringList('phoneList', phones);
    await prefs.setStringList('emailList', emails);
    await prefs.setStringList('imageAddressList', imageAddresses);
  }
}
