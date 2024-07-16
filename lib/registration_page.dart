import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmationCodeController = TextEditingController();
  bool _isConfirmationMode = false;
  String _username = '';
  bool _isCodeCorrect = false;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'RU');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;
    final String phoneNumber = _phoneNumber.phoneNumber ?? '';

    if (username.isEmpty || password.isEmpty || email.isEmpty || phoneNumber.isEmpty) {
      _showSnackBar('Пожалуйста, заполните все поля');
      return;
    }

    try {
      final response = await _performRegistration(username, password, email, phoneNumber);
      if (response.statusCode == 200) {
        _showSnackBar('Регистрация успешна! Проверьте ваш телефон для подтверждения.');
        setState(() {
          _isConfirmationMode = true;
          _username = username;
        });
      } else {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('username')) {
          _showSnackBar('Ошибка: Логин уже используется.');
        } else if (responseData.containsKey('email')) {
          _showSnackBar('Ошибка: Email уже используется.');
        } else if (responseData.containsKey('phone_number')) {
          _showSnackBar('Ошибка: Номер телефона уже используется.');
        } else {
          _showSnackBar('Ошибка: ${responseData['detail'] ?? 'Попробуйте позже.'}');
        }
      }
    } catch (e) {
      _showSnackBar('Ошибка при регистрации. Попробуйте позже.');
    }
  }

  Future<http.Response> _performRegistration(String username, String password, String email, String phoneNumber) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/register/');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password, 'email': email, 'phone_number': phoneNumber}),
    );
  }

  Future<void> _confirmCode() async {
    final String confirmationCode = _confirmationCodeController.text;

    if (confirmationCode.isEmpty) {
      _showSnackBar('Пожалуйста, введите код подтверждения');
      return;
    }

    try {
      final response = await _performConfirmation(_username, confirmationCode);
      if (response.statusCode == 200) {
        setState(() {
          _isCodeCorrect = true;
        });
        _showSnackBar('Телефон подтвержден! Теперь вы можете войти.');
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _isCodeCorrect = false;
        });
        _showSnackBar('Ошибка: Неправильный код подтверждения.');
      }
    } catch (e) {
      setState(() {
        _isCodeCorrect = false;
      });
      _showSnackBar('Ошибка при подтверждении. Попробуйте позже.');
    }
  }

  Future<http.Response> _performConfirmation(String username, String confirmationCode) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/confirm-code/');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'confirmation_code': confirmationCode}),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isConfirmationMode ? 'Подтверждение телефона' : 'Регистрация'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isConfirmationMode)
              Column(
                children: <Widget>[
                  Text(
                    'Введите код подтверждения, отправленный на ваш телефон',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  PinCodeTextField(
                    appContext: context,
                    length: 5,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 35,
                      activeFillColor: _isCodeCorrect ? Colors.green : Colors.red,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      activeColor: _isCodeCorrect ? Colors.green : Colors.red,
                      selectedColor: Colors.blue,
                      inactiveColor: Colors.grey,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: Duration(milliseconds: 300),
                    enableActiveFill: true,
                    controller: _confirmationCodeController,
                    onCompleted: (code) {
                      _confirmCode();
                    },
                    onChanged: (value) {
                      setState(() {
                        _isCodeCorrect = false;
                      });
                    },
                  ),
                ],
              )
            else
              Column(
                children: <Widget>[
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
                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.email,
                    label: 'Email',
                  ),
                  const SizedBox(height: 20),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        _phoneNumber = number;
                      });
                    },
                    onInputValidated: (bool value) {
                      print(value);
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DROPDOWN,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: Colors.black),
                    initialValue: _phoneNumber,
                    formatInput: false,
                    keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                    inputDecoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone),
                      labelText: 'Телефон',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    child: const Text('Регистрация', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
          ],
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: isPassword,
    );
  }
}
