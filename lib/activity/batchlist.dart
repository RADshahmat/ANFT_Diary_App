import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:anft_app/activity/datadetail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
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
        primarySwatch: Colors.purple,
        hintColor: Colors.purpleAccent,
      ),
      home: BatchList(),
    );
  }
}

class BatchList extends StatefulWidget {
  @override
  _BatchListState createState() => _BatchListState();
}

class _BatchListState extends State<BatchList> {
  final List<String> _dataList1 = [];
  bool spinner = false;
  String jsonData = '';
  bool isSearchBarVisible = false;
  String kaka = '';
  double searchBarWidth = 0.0;
  TextEditingController searchController = TextEditingController();
  List<String> searchResults = [];
  List<String> searchResults12 = [];
  List<String> searchResults123 = [];
  double progress = 0;

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
    _loadSavedData();
  }

  Future<void> _checkInternetConnectivity2() async {
    final url = Uri.parse('https://www.google.com');
    final client = http.Client();
    progress = 0;

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        print('Connected to the internet');
        getData1();
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
          getData1();

          await _setFirstRunFlag(false);
        } else {
          final lastFetchDate = await _getLastFetchDate();
          final currentDate = DateTime.now();
          if (lastFetchDate == null ||
              currentDate.difference(lastFetchDate).inDays >= 5 ||
              (_dataList1.isEmpty && jsonData.isEmpty)) {
            getData1();

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

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedDataList1 = prefs.getStringList('dataList') ?? [];
    String savedJsonData = prefs.getString('studentData') ?? '';

    setState(() {
      _dataList1.clear();
      _dataList1.addAll(savedDataList1);
      jsonData = savedJsonData;
    });
  }

  List<String> _filterData1(String query) {
    List<String> filteredResults = [];

    if (query.isEmpty) {
      return filteredResults;
    }

    final data = jsonDecode(jsonData);
    for (var item in data) {
      final name = item['Name'].toString();
      final batch = item['Batch'].toString();
      final Session = item['Session'].toString();
      final work = item['CurrentWorkplace'].toString();
      final address = item['PermanentAddress'].toString();
      final address1 = address.toLowerCase();
      final work1 = work.toLowerCase();
      final name1 = name.toLowerCase();
      if (name1.contains(query.toLowerCase()) ||
          work1.contains(query.toLowerCase()) ||
          address1.contains(query.toLowerCase())) {
        String det = name +
            '  [' +
            '(' +
            batch +
            ' Batch,  ' +
            Session +
            ')' +
            '\n' +
            work;
        filteredResults.add(det);
      }
    }

    return filteredResults;
  }

  List<String> _filterData(String query) {
    List<String> filteredResults = [];

    if (query.isEmpty) {
      return filteredResults;
    }

    final data = jsonDecode(jsonData);
    for (var item in data) {
      final name = item['Name'].toString();
      final address = item['PermanentAddress'].toString();
      final address1 = address.toLowerCase();
      final name1 = name.toLowerCase();
      final work = item['CurrentWorkplace'].toString().toLowerCase();
      if (name1.contains(query.toLowerCase()) ||
          work.contains(query.toLowerCase()) ||
          address1.contains(query.toLowerCase())) {
        filteredResults.add(name);
      }
    }

    return filteredResults;
  }

  List<String> _filterData12(String query) {
    List<String> filteredResults = [];

    if (query.isEmpty) {
      return filteredResults;
    }

    final data = jsonDecode(jsonData);
    for (var item in data) {
      final name = item['Name'].toString();
      final address = item['PermanentAddress'].toString();
      final address1 = address.toLowerCase();
      final name1 = name.toLowerCase();
      final work = item['CurrentWorkplace'].toString().toLowerCase();
      if (name1.contains(query.toLowerCase()) ||
          work.contains(query.toLowerCase()) ||
          address1.contains(query.toLowerCase())) {
        filteredResults.add(address);
      }
    }

    return filteredResults;
  }

  void viewStudentDetails(String selectedName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => StudentDetailsScreen(
          selectedName: selectedName,
          jsonData: jsonData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: searchBarWidth,
                padding: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter student name',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchResults = _filterData(value);
                      searchResults12 = _filterData1(value);
                      searchResults123 = _filterData12(value);
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: AnimatedOpacity(
                opacity: isSearchBarVisible ? 0.0 : 1.0,
                duration: Duration(milliseconds: 300),
                child: spinner
                    ? Container(
                        child: Text(
                          'Downloading Please Wait...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(
                        child: Text(
                          "Student's Information",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(isSearchBarVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearchBarVisible = !isSearchBarVisible;
                if (isSearchBarVisible) {
                  searchBarWidth = 230.0;
                } else {
                  searchBarWidth = 0.0;
                }
              });
            },
          ),
        ],
      ),
      body: isSearchBarVisible
          ? ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (ctx, index) {
                final name = searchResults[index];
                final name12 = searchResults12[index];
                final name123 = searchResults123[index];
                final List<String> nameLines = name12.split('\n');
                String firstLine = '';
                String secondLine = '';

                if (nameLines.isNotEmpty) {
                  firstLine = nameLines[0];
                  if (nameLines.length > 1) {
                    secondLine = nameLines[1];
                  }
                }

                return GestureDetector(
                  onTap: () {
                    viewStudentDetails(name);
                  },
                  child: Card(
                    elevation: 3,
                    margin: EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Container(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: firstLine.split('[')[0],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 19,
                                      color: Color.fromARGB(255, 31, 131, 238),
                                    ),
                                  ),
                                  TextSpan(
                                    text: firstLine.split('[')[1],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              secondLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 6),
                            Text(
                              name123,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _checkInternetConnectivity2();
              },
              child: ListView.builder(
                itemCount: spinner ? 1 : _dataList1.length ~/ 2,
                itemBuilder: (ctx, index) {
                  if (spinner && index == 0) {
                    double screenHeight =
                        MediaQuery.of(context).size.height / 2.5;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: screenHeight),
                          alignment: Alignment.center,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          width: 250,
                          child: Stack(
                            children: <Widget>[
                              LinearPercentIndicator(
                                percent: progress,
                                animation: true,
                                animationDuration: 10,
                                lineHeight: 18,
                                barRadius: Radius.circular(15),
                                backgroundColor:
                                    const Color.fromARGB(255, 225, 213, 213),
                                progressColor: Colors.blue,
                              ),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 45, 42, 42),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    final batch = _dataList1[index];
                    final year = _dataList1[index + _dataList1.length ~/ 2];

                    return GestureDetector(
                      onTap: () {
                        viewDataDetail(context, batch, jsonData);
                      },
                      child: Card(
                        elevation: 3,
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              '$batch Batch',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            subtitle: Text(
                              '($year)',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }

  Future<void> getData1() async {
    setState(() {
      spinner = true;
    });
    List<String> extractedNames = [];
    List<dynamic> data = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    var url = '${baseUrl}get1.php';

    try {
      http.Response response = await http.get(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token', // Send token in header
        },);

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        for (var item in responseData) {
          if (item.containsKey('Batch')) {
            extractedNames.add(item['Batch']);
          }
        }
      } else {
        setState(() {
          spinner = false;
        });

        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        spinner = false;
      });
    }

    for (int i = 0; i < extractedNames.length / 2; i++) {
      url =
          '${baseUrl}get.php?flag=${extractedNames[i]}';

      try {
        http.Response response = await http.get(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          var responseData = jsonDecode(response.body);
          data.addAll(responseData);
        } else {
          setState(() {
            spinner = false;
          });

          print('Request failed with status: ${response.statusCode}');
        }
      } catch (error) {
        print('Error fetching data: $error');
        setState(() {
          spinner = false;
        });
      }

      if (!mounted) break;
      setState(() {
        progress = (2 / extractedNames.length) * (i + 1);
      });
    }
    if (!mounted) return;
    jsonData = jsonEncode(data);
    _saveStudentDataToSharedPreferences(jsonData);

    await getData();
  }

  Future<void> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token'); // Retrieve token from SharedPreferences

    var url = '${baseUrl}get1.php';

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

        for (var item in data) {
          if (item.containsKey('Batch')) {
            extractedNames.add(item['Batch']);
          }
        }

        setState(() {
          _dataList1.clear();
          _dataList1.addAll(extractedNames);
          _saveDataToLocal(extractedNames);
          spinner = false;
        });
      } else {
        setState(() {
          spinner = false;
        });
      }
    } catch (error) {
      setState(() {
        spinner = false;
      });
    }
  }

  Future<void> _saveDataToLocal(List<String> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('dataList', data);
  }

  Future<void> _saveStudentDataToSharedPreferences(String jsonData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentData', jsonData);
  }

  Future<bool> _isFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstRun') ?? true;
  }

  Future<void> _setFirstRunFlag(bool isFirstRun) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun', isFirstRun);
  }

  Future<DateTime?> _getLastFetchDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getString('lastFetchTimestamp');
    if (lastFetchTimestamp != null) {
      return DateTime.parse(lastFetchTimestamp);
    }
    return null;
  }

  Future<void> _setLastFetchDate(DateTime dateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFetchTimestamp', dateTime.toIso8601String());
  }
}

class StudentDetailsScreen extends StatelessWidget {
  final String selectedName;
  final String jsonData;

  StudentDetailsScreen({
    required this.selectedName,
    required this.jsonData,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> data = jsonDecode(jsonData);
    Map<String, dynamic>? studentData;

    for (var item in data) {
      final name = item['Name'].toString();
      if (name == selectedName) {
        studentData = item;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedName),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            studentData?['Name'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                          indent: 16.0,
                          endIndent: 16.0,
                        ),
                        ListTile(
                          title: Text(
                            'Phone Number:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            studentData?['PhoneNumber'] ?? 'N/A',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                          indent: 16.0,
                          endIndent: 16.0,
                        ),
                        ListTile(
                          title: Text(
                            'Email:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            studentData?['Email'] ?? 'N/A',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                          indent: 16.0,
                          endIndent: 16.0,
                        ),
                        ListTile(
                          title: Text(
                            'Designation:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            studentData?['Designation'] ?? 'N/A',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                          indent: 16.0,
                          endIndent: 16.0,
                        ),
                        ListTile(
                          title: Text(
                            'Current Workplace:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            studentData?['CurrentWorkplace'] ?? 'N/A',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Divider(
                          color: Colors.grey,
                          thickness: 1.0,
                          indent: 16.0,
                          endIndent: 16.0,
                        ),
                        ListTile(
                          title: Text(
                            'Address:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            studentData?['PermanentAddress'] ?? 'N/A',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.call),
                                  color: Colors.teal,
                                  onPressed: () {
                                    if (studentData?['PhoneNumber'] == 'N/A' ||
                                        studentData?['PhoneNumber'] == 'na') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("No Phone Number"),
                                            content: Text(
                                                "This contact doesn't have a phone number."),
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
                                    } else {
                                      launch(
                                          "tel:${studentData?['PhoneNumber']}");
                                    }
                                  },
                                ),
                                Text('Call'),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.message),
                                  color: Colors.teal,
                                  onPressed: () {
                                    if (studentData?['PhoneNumber'] == 'N/A' ||
                                        studentData?['PhoneNumber'] == 'na') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("No Phone Number"),
                                            content: Text(
                                                "This contact doesn't have a phone number."),
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
                                    } else {
                                      launch(
                                          "sms:${studentData?['PhoneNumber']}");
                                    }
                                  },
                                ),
                                Text('Message'),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.email),
                                  color: Colors.teal,
                                  onPressed: () {
                                    if (studentData?['Email'] == 'N/A' ||
                                        studentData?['Email'] == 'na') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("No Email Address"),
                                            content: Text(
                                                "This contact doesn't have an email address."),
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
                                    } else {
                                      launch("mailto:${studentData?['Email']}");
                                    }
                                  },
                                ),
                                Text('Email'),
                              ],
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
        ),
      ),
    );
  }
}
