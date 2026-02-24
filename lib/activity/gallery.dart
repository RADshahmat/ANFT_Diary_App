import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late List<String> imageUrls = [];
  // ignore: unused_field
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _checkInternetConnectivity();
    _loadDataFromSharedPreferences();
  }

  Future<void> _saveDataToSharedPreferences(List<String> urls) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('imageUrls', urls);
  }

  Future<void> _loadDataFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      imageUrls = prefs.getStringList('imageUrls') ?? [];
    });
  }

  Future<void> _checkInternetConnectivity() async {
    final url = Uri.parse('https://www.google.com');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Connected to the internet');
        final isFirstRun = await _isFirstRun();
        if (isFirstRun) {
          await getData2();
          await _setFirstRunFlag(false);
        } else {
          final lastFetchDate = await _getLastFetchDate();
          final currentDate = DateTime.now();
          if (lastFetchDate == null ||
              currentDate.difference(lastFetchDate).inDays >= 30) {
            await getData2();
            await _setLastFetchDate(currentDate);
          }
        }
      } else {
        print('Not connected to the internet');
      }
    } on SocketException catch (_) {
      print('Not connected to the internet');
    }
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

  Future<void> getData2() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    final apiUrl = Uri.parse('${baseUrl}getimg.php');

    try {
      final response = await http.get(apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token', // Send token in header
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<String> notice = [];

        for (var item in jsonData) {
          if (item.containsKey('imageAddress')) {
            notice.add(item['imageAddress']);
          }
        }
        setState(() {
          imageUrls.clear();
          imageUrls.addAll(notice);
        });
        await _saveDataToSharedPreferences(imageUrls);
      } else {
        print('Failed to fetch holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _openFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Image Viewer'),
          ),
          body: PhotoViewGallery.builder(
            itemCount: imageUrls.length,
            pageController: PageController(initialPage: initialIndex),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            builder: (context, index) {
              String imageUrl =
                  '${baseUrl}${imageUrls[index]}';
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
              );
            },
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
        ),
      ),
    );
  }

  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await getData2();
    setState(() {
      _isRefreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isRefreshing
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _handleRefresh,
                  ),
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          String imageUrl =
              '${baseUrl}${imageUrls[index]}';

          return GestureDetector(
              onTap: () {
                _openFullScreenGallery(index);
              },
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/drawer_iu.jpg',
                    fit: BoxFit.cover,
                  );
                },
              ));
        },
      ),
    );
  }
}
