import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;

  Future<void> _fetchProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rollNo = prefs.getString('roll_no');
    final password = prefs.getString('user_password');
    String? token = prefs.getString('jwt_token');
    final url = '${baseUrl}profilegetapi.php';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'authorization': 'Bearer $token', // Send token in header
      },
      body: jsonEncode({'RollNo': rollNo, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          _profileData = responseData['data'];
        });
      }
    }
  }

  Future<void> _changePassword() async {
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();
    bool _isNewPasswordVisible = false;
    bool _isConfirmPasswordVisible = false;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rollNo = prefs.getString('roll_no');
    final password = prefs.getString('user_password');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_isNewPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible ? Icons.visibility : Icons
                              .visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons
                              .visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final newPassword = _newPasswordController.text.trim();
                    final confirmPassword = _confirmPasswordController.text
                        .trim();

                    if (newPassword.isEmpty || confirmPassword.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'All fields are required')),
                      );
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                      return;
                    }
                    String? token = prefs.getString('jwt_token');
                    final url = '${baseUrl}profileupdateapi.php';
                    final response = await http.post(
                      Uri.parse(url),
                      headers: {
                        'Content-Type': 'application/json',
                        'authorization': 'Bearer $token', // Send token in header
                      },
                      body: jsonEncode({
                        'RollNo': rollNo,
                        'password': password,
                        'newPassword': newPassword,
                        'confirmPassword': confirmPassword,
                      }),
                    );

                    if (response.statusCode == 200) {
                      final responseData = jsonDecode(response.body);
                      if (responseData['status'] == 'success') {
                        await prefs.setString('user_password', newPassword);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password updated successfully!')),
                        );
                        Navigator.pop(context); // Close the dialog
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(responseData['message'] ??
                              'Failed to update password')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Failed to update password')),
                      );
                    }
                  },
                  child: const Text(
                    'Save', style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: _profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.indigo[100],
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile.jpg',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _profileData!['Name'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            iconSize: 20,
                            icon: const Icon(Icons.edit, color: Colors.grey),
                            onPressed: () =>
                                _editProfileData(
                                  context,
                                  'Name',
                                  _profileData!['Name'] ?? '',
                                  'Name',
                                ),
                          ),
                        ],
                      ),
                      Text(
                        'Batch: ${_profileData!['Batch']}, Session: ${_profileData!['Session']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Roll No: ${_profileData!['RollNo']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _changePassword,
                    child: const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCard(context, 'Workplace', _profileData!['CurrentWorkplace'],
                'CurrentWorkplace'),
            _buildCard(context, 'Designation', _profileData!['Designation'],
                'Designation'),
            _buildCard(
                context, 'Permanent Address', _profileData!['PermanentAddress'],
                'Address'),
            _buildCard(context, 'Email', _profileData!['Email'], 'Email'),
            _buildCard(context, 'Phone Number', _profileData!['PhoneNumber'],
                'PhoneNumber'),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String? value,
      String fieldKey) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          _getIconForTitle(title),
          color: Colors.blue,
        ),
        title: Text(title),
        subtitle: Text(value ?? 'N/A'),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () =>
              _editProfileData(context, title, value ?? '', fieldKey),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Workplace':
        return Icons.work;
      case 'Designation':
        return Icons.badge;
      case 'Permanent Address':
        return Icons.home;
      case 'Email':
        return Icons.email;
      case 'Phone Number':
        return Icons.phone;
      default:
        return Icons.info;
    }
  }

  Future<void> _editProfileData(BuildContext context,
      String title,
      String currentValue,
      String fieldKey,) async {
    TextEditingController _controller = TextEditingController(
        text: currentValue);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final rollNo = prefs.getString('roll_no');
    final password = prefs.getString('user_password');

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Add padding inside the dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit $title',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: title,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Rounded text field
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Custom button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Rounded button
                        ),
                      ),
                      onPressed: () async {
                        final newValue = _controller.text.trim();
                        if (newValue.isNotEmpty) {
                          String? token = prefs.getString('jwt_token');
                          final url = '${baseUrl}profileupdateapi.php';
                          final response = await http.post(
                            Uri.parse(url),
                            headers: {
                              'Content-Type': 'application/json',
                              'authorization': 'Bearer $token', // Send token in header
                            },
                            body: jsonEncode({
                              'RollNo': rollNo,
                              'password': password,
                              'field': fieldKey,
                              'newValue': newValue,
                            }),
                          );

                          if (response.statusCode == 200) {
                            final responseData = jsonDecode(response.body);
                            if (responseData['status'] == 'success') {
                              _fetchProfileData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                    '$title updated successfully!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Failed to update $title.')),
                              );
                            }
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
