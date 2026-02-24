import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
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
        primaryColor: Colors.purple,
        hintColor: Colors.purpleAccent,
        fontFamily: 'Roboto',
      ),
      home: Courses(),
    );
  }
}

class Courses extends StatefulWidget {
  @override
  _CoursesState createState() => _CoursesState();
}

class _CoursesState extends State<Courses> {
  String jsonData1 = '';
  String selectedYear = "First";
  String selectedSemester = "1st";
  String selectedType = "B.Sc";

  List<dynamic> filteredData = [];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _checkInternetConnectivity();
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
              currentDate.difference(lastFetchDate).inSeconds >= 3 ||
              jsonData1.isEmpty) {
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
    return prefs.getBool('isFirstRun3') ?? true;
  }

  Future<void> _setFirstRunFlag(bool isFirstRun) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstRun3', isFirstRun);
  }

  Future<DateTime?> _getLastFetchDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getString('lastFetchTimestamp3');
    if (lastFetchTimestamp != null) {
      return DateTime.parse(lastFetchTimestamp);
    }
    return null;
  }

  Future<void> _setLastFetchDate(DateTime dateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastFetchTimestamp3', dateTime.toIso8601String());
  }

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDataList = prefs.getString('dataList11');

    if (savedDataList != null) {
      setState(() {
        jsonData1 = savedDataList;
        filterDataByYearAndSemester();
      });
    }
  }

  void filterDataByYearAndSemester() {
    if (jsonData1.isNotEmpty) {
      List<dynamic> allData = jsonDecode(jsonData1);
      filteredData = allData
          .where((data) =>
      data['Type'] == selectedType &&
          data['year'] == selectedYear &&
          data['Semester'] == selectedSemester)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Degree:',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: selectedType,
                      onChanged: (newValue) {
                        setState(() {
                          selectedType = newValue!;
                          if (selectedType == "M.Sc") {
                            selectedYear = 'First';
                          }
                          filterDataByYearAndSemester();
                        });
                      },
                      items: ["B.Sc", "M.Sc"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (selectedType == "B.Sc")
                  Column(
                    children: [
                      Text(
                        'Year:',
                        style: TextStyle(fontSize: 16),
                      ),
                      DropdownButton<String>(
                        value: selectedYear,
                        onChanged: (newValue) {
                          setState(() {
                            selectedYear = newValue!;
                            filterDataByYearAndSemester();
                          });
                        },
                        items: ["First", "Second", "Third", "Fourth"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                Column(
                  children: [
                    Text(
                      'Semester:',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: selectedSemester,
                      onChanged: (newValue) {
                        setState(() {
                          selectedSemester = newValue!;
                          filterDataByYearAndSemester();
                        });
                      },
                      items: (selectedType == "B.Sc"
                          ? ["1st", "2nd"]
                          : ["1st", "2nd", "3rd"])
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredData.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 4,
                  child: ListTile(
                      title: Text(
                        filteredData[index]['CourseTitile'],
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        '${filteredData[index]['CourseNo']}, Credit: ${filteredData[index]['credit']}',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        /* String pdfFileName = filteredData[index]['CourseNo']
                                .replaceAll('-', '_')
                                .replaceAll('(Practical)', '  ')
                                .replaceAll(' ', '')
                                .toLowerCase() +
                            '.pdf';

                        print(pdfFileName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PdfViewerPage(pdfUrl: pdfFileName),
                          ),
                        );*/
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    var url = '${baseUrl}get4.php';

    try {
      http.Response response = await http.get(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token', // Send token in header
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          jsonData1 = jsonEncode(data);
          print(jsonData1);
          _saveDataToLocal(jsonData1);
          filterDataByYearAndSemester();
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _saveDataToLocal(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('dataList11', data);
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  PdfViewerPage({required this.pdfUrl});

  Future<String?> preparePdf() async {
    try {
      ByteData data = await rootBundle.load('assets/pdf/$pdfUrl');
      List<int> bytes = data.buffer.asUint8List();
      String path = (await getTemporaryDirectory()).path;
      String pdfPath = '$path/$pdfUrl';
      await File(pdfPath).writeAsBytes(bytes);
      return pdfPath;
    } catch (e) {
      print('Error preparing PDF: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Inside the class: $pdfUrl");
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
      ),
      body: Center(
        child: FutureBuilder<String?>(
          future: preparePdf(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              try {
                if (snapshot.hasError) {
                  throw Exception('Error: ${snapshot.error}');
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return PDFView(
                    filePath: snapshot.data!,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: false,
                    onRender: (pages) {
                      print('PDF rendered with $pages pages.');
                    },
                  );
                } else {
                  return Text(
                    'No content available',
                    style: TextStyle(
                        fontSize: 18, color: Color.fromARGB(255, 255, 0, 17)),
                  );
                }
              } catch (e) {
                return Text(
                  'No content available',
                  style: TextStyle(fontSize: 18),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
