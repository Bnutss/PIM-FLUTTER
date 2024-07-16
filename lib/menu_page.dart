import 'package:flutter/material.dart';
import 'materials_page.dart';
import 'create_coming_page.dart';
import 'create_expenses_page.dart';

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Меню',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Color(0xFF696969),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Приход',
              icon: Icons.input,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateComingPage()),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Расход',
              icon: Icons.output,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateExpensesPage()),
                );
              },
            ),
            SizedBox(height: 20),
            CustomButton(
              text: 'Материалы',
              icon: Icons.build,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MaterialsPage()),
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
