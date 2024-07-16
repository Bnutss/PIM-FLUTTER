import 'package:flutter/material.dart';
import 'menu_page.dart';
import 'result_page.dart';
import 'remainder_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Меню',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Color(0xFF696969),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Добавить',
              icon: Icons.add,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage()),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Итоги',
              icon: Icons.calendar_today,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResultPage()),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Остаток',
              icon: Icons.inventory,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RemainderPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shadowColor: Colors.tealAccent,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
