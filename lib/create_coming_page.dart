import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateComingPage extends StatefulWidget {
  @override
  _CreateComingPageState createState() => _CreateComingPageState();
}

class _CreateComingPageState extends State<CreateComingPage> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String selectedStock = '';
  String selectedMaterial = '';
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> materials = [];

  @override
  void initState() {
    super.initState();
    _fetchStocks();
    _fetchMaterials();
  }

  Future<void> _fetchStocks() async {
    try {
      final response = await http.get(
        Uri.parse('http://progressim.pythonanywhere.com/api/stock/'),
        headers: {'Accept-Charset': 'UTF-8'},
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          stocks = List<Map<String, dynamic>>.from(decodedData);
        });
      } else {
        print('Error fetching stocks: ${response.body}');
      }
    } catch (e) {
      print('Exception when fetching stocks: $e');
    }
  }

  Future<void> _fetchMaterials() async {
    try {
      final response = await http.get(
        Uri.parse('http://progressim.pythonanywhere.com/api/materials/'),
        headers: {'Accept-Charset': 'UTF-8'},
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          materials = List<Map<String, dynamic>>.from(decodedData);
        });
      } else {
        print('Error fetching materials: ${response.body}');
      }
    } catch (e) {
      print('Exception when fetching materials: $e');
    }
  }

  void _createComing() async {
    if (selectedStock.isEmpty || selectedMaterial.isEmpty || quantityController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Все поля должны быть заполнены')),
      );
      return;
    }

    final String url = 'http://progressim.pythonanywhere.com/api/coming/';
    final Map<String, dynamic> body = {
      'stock': int.parse(selectedStock),
      'material': int.parse(selectedMaterial),
      'quantity': double.parse(quantityController.text),
      'price': double.parse(priceController.text.replaceAll(' ', '')),
      'arrival_date': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Приход успешно создан', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          quantityController.clear();
          priceController.clear();
          selectedStock = '';
          selectedMaterial = '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании прихода: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Исключение при создании прихода: $e')),
      );
    }
  }

  String _formatPrice(String value) {
    return value.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создание Прихода', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Склад',
                border: OutlineInputBorder(),
              ),
              items: stocks.map<DropdownMenuItem<String>>((stock) {
                return DropdownMenuItem<String>(
                  value: stock['id'].toString(),
                  child: Text(stock['name_stock'] ?? 'Неизвестный склад'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStock = value ?? '';
                });
              },
              value: selectedStock.isNotEmpty ? selectedStock : null,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Материал',
                border: OutlineInputBorder(),
              ),
              items: materials.map<DropdownMenuItem<String>>((material) {
                return DropdownMenuItem<String>(
                  value: material['id'].toString(),
                  child: Text(material['name'] ?? 'Неизвестный материал'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMaterial = value ?? '';
                });
              },
              value: selectedMaterial.isNotEmpty ? selectedMaterial : null,
            ),
            SizedBox(height: 20),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Количество',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Цена',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                setState(() {
                  priceController.text = _formatPrice(value.replaceAll(' ', ''));
                  priceController.selection = TextSelection.fromPosition(TextPosition(offset: priceController.text.length));
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createComing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Сохранить', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
