import 'dart:convert';
import 'config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _selectedLoginType = 'Student'; // Default selection

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final url = '${baseUrl}loginapi.php';
    final body = {
      'RollNo': _selectedLoginType == 'Student' ? _rollNoController.text.trim() : '',
      'password': _passwordController.text.trim(),
      'userType': _selectedLoginType,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          prefs.setString('jwt_token', responseData['token']);
          prefs.setString('login_type', _selectedLoginType);

          if (_selectedLoginType == 'Student') {
            await prefs.setString('roll_no', _rollNoController.text.trim());
            await prefs.setString('user_password', _passwordController.text.trim());
          } else {
            await prefs.setString('user_password', _passwordController.text.trim());
          }

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError(responseData['message'] ?? 'Login failed.');
        }
      } else {
        _showError('Server error. Please try again later.');
      }
    } catch (e) {
      _showError('Failed to connect to the server.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Login",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 20),

                    // Login Type Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _loginTypeButton('Student'),
                        const SizedBox(width: 10),
                        _loginTypeButton('Faculty'),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Roll Number Field (Only for Students)
                    if (_selectedLoginType == 'Student') ...[
                      _buildTextField(_rollNoController, "Roll Number", Icons.person),
                      const SizedBox(height: 16),
                    ],

                    // Password Field
                    _buildTextField(_passwordController, "Password", Icons.lock, isPassword: true),
                    const SizedBox(height: 24),

                    // Login Button
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to build text fields
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Function to create Login Type Buttons
  Widget _loginTypeButton(String type) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedLoginType = type;
            _rollNoController.clear();
            _passwordController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _selectedLoginType == type ? Colors.indigo : Colors.grey[300],
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: TextStyle(
              color: _selectedLoginType == type ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
