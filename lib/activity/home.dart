import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:anft_app/activity/batchlist.dart';
import 'package:anft_app/activity/teachers.dart';
import 'package:anft_app/activity/staff.dart';
import 'package:anft_app/activity/cource.dart';
import 'package:anft_app/activity/NoticeSection.dart';
import 'package:anft_app/activity/about.dart';
import 'package:anft_app/activity/info.dart';
import 'package:anft_app/activity/gallery.dart';
import 'package:anft_app/activity/ProfilePage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? loginType;
  List<String> _notice = [];
  List<String> _noticeDetails = [];


  Future<bool> _checkInternetConnectivity() async {
    final url = Uri.parse('https://www.google.com');
    final client = http.Client();

    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        print('Connected to the internet');

        // Perform first run or periodic data fetch if needed
        final isFirstRun = await _isFirstRun();
        if (isFirstRun) {
          await getData2();
          await _setFirstRunFlag(false);
        } else {
          final lastFetchDate = await _getLastFetchDate();
          final currentDate = DateTime.now();
          if (lastFetchDate == null ||
              currentDate.difference(lastFetchDate).inHours >= 1) {
            await getData2();
            await _setLastFetchDate(currentDate);
          }
        }

        return true; // Internet is available
      } else {
        print('Not connected to the internet');
      }
    } on SocketException catch (_) {
      print('Not connected to the internet');
    } finally {
      client.close();
    }

    return false; // No internet connection
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

  String? _latestCurrentDateNoticeTitle;

  Future<void> getData2() async {
    final apiUrl = Uri.parse('${baseUrl}noticegetapi.php');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    try {
      final response = await http.get(apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token', // Send token in header
        },
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}"); // Debug: Print the API response

        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final notices = jsonData['data'] as List<dynamic>;

          final today = DateTime.now(); // Get the current date
          final currentDate = DateFormat('yyyy-MM-dd').format(today);

          setState(() {
            // Populate all notices
            _notice = notices.map((e) => e['title'].toString()).toList();
            _noticeDetails = notices.map((e) {
              final dateTime = "${e['date']} ${e['time']}";
              return "Date: $dateTime\n${e['details']}\nAttachment: ${e['attachment']}";
            }).toList();

            // Find the latest notice for the current date
            final currentDateNotices = notices.where((e) => e['date'] == currentDate).toList();

            if (currentDateNotices.isNotEmpty) {
              // Sort by time to get the latest notice for the current date
              currentDateNotices.sort((a, b) => b['time'].compareTo(a['time']));
              _latestCurrentDateNoticeTitle = currentDateNotices.first['title'].toString();
            } else {
              _latestCurrentDateNoticeTitle = null; // No current date notices
            }
          });

          print("Notices: $_notice"); // Debug: Print the notices
          print("Latest Current Date Notice: $_latestCurrentDateNoticeTitle"); // Debug: Print the latest current date notice
        } else {
          print("Error: ${jsonData['message']}"); // Debug: Handle error in API response
        }
      } else {
        print('Failed to fetch notices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    // Clear credentials from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('roll_no');
    await prefs.remove('user_password');

    // Navigate to the root route
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _getLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loginType = prefs.getString('login_type');
    });
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnectivity();
    getData2();
    _getLoginType();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: _latestCurrentDateNoticeTitle != null
            ? GestureDetector(
          onTap: () {
            // Navigate to the All Notices page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllNoticesPage(
                  noticeTitles: _notice,
                  noticeDetails: _noticeDetails,
                ),
              ),
            );
          },
          child: Card(
            elevation: 0,
            margin: EdgeInsets.only(top: 2),
            shape: RoundedRectangleBorder(),
            child: Container(
              height: 80,
              width: double.infinity,
              color: Colors.indigo,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Marquee(
                    text: 'Latest Notice: ** $_latestCurrentDateNoticeTitle ** tap to view',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.yellow,
                    ),
                    scrollAxis: Axis.horizontal,
                    blankSpace: 260.0,
                    velocity: 40.0,
                    startPadding: 10.0,
                    pauseAfterRound: Duration(seconds: 1),
                  ),
                ),
              ),
            ),
          ),
        )
            : Container(), // Show a blank container if no current date notice
      ),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 255, 248, 248),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: MediaQuery.of(context).size.width / 200,
                  viewportFraction: 1,
                ),
                items: [
                  'assets/images/Kushtia_Islamic_University_Auditorium,_Kushtia,_Bangladesh.jpg',
                  'assets/images/drawer_iu.jpg',
                  'assets/images/iu3.jpg',
                ].map((item) {
                  return Container(
                    width: double.infinity,
                    child: Image.asset(
                      item,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
            ),
            Column(
              children: [
                if (loginType != 'Faculty')
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: ListTile(
                    leading: Icon(Icons.perm_contact_cal_outlined),
                    title: const Text(
                      'My Profile',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                      onTap: () async {
                        Navigator.pop(context); // Close the sidebar

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        }
                  ),
                ),
              ],
            ),
            Container(
              child: ListTile(
                leading: Icon(Icons.notification_important_rounded),
                title: const Text(
                  'Notice Board',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the sidebar
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllNoticesPage(
                        noticeTitles: _notice,       // Pass the notice titles
                        noticeDetails: _noticeDetails, // Pass the notice details
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              child: ListTile(
                leading: Icon(Icons.photo_library),
                title: const Text('Gallery',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GalleryScreen(),
                    ),
                  );
                },
              ),
            ),
            Container(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('About',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutDeveloperPage(),
                    ),
                  );
                },
              ),
            ),
            Container(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.indigo,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                  title: Text(
                      'Department of \nApplied Nutrition and \nFood Technology,',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white)),
                  subtitle: Text('Islamic University, Kushtia',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white54)),
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            return AboutDepartmentPage();
                          },
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                          'assets/images/anft_dept-removebg-preview.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 50)
              ],
            ),
          ),
          Container(
            color: Colors.indigo,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 10),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 40,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Teachers()),
                        );
                      },
                      child: itemDashboard(
                        'Faculties',
                        Icons.school,
                        Colors.deepOrange,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => BatchList()),
                        );
                      },
                      child: itemDashboard(
                        'Students',
                        CupertinoIcons.rectangle_stack_person_crop,
                        Colors.green,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => staff()),
                        );
                      },
                      child: itemDashboard(
                          'Office Staff', Icons.business, Colors.teal),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Courses()),
                        );
                      },
                      child: itemDashboard(
                        'Courses',
                        CupertinoIcons.book,
                        Colors.blue,
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

  Widget itemDashboard(String title, IconData iconData, Color background) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Theme.of(context).primaryColor.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          )
        ],
      ),
    );
  }
}
