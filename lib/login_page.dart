import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'home_page.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('Пожалуйста, введите логин и пароль');
      return;
    }

    try {
      final response = await _performLogin(username, password);
      if (response.statusCode == 200) {
        _navigateToHomePage();
      } else {
        _showSnackBar('Неверный логин или пароль');
      }
    } catch (e) {
      _showSnackBar('Ошибка при входе. Попробуйте позже.');
    }
  }

  Future<http.Response> _performLogin(String username, String password) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/login/');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
  }

  void _navigateToRegistrationPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegistrationPage()));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logoProgress.png', height: 250),
                const SizedBox(height: 20),
                AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      'Добро пожаловать!',
                      textStyle: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Sweet Mavka Script',
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 1000),
                  displayFullTextOnTap: true,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _usernameController,
                  icon: Icons.person,
                  label: 'Логин',
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock,
                  label: 'Пароль',
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Вход', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToRegistrationPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Регистрация', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: isPassword,
    );
  }
}
