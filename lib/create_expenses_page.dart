import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CreateExpensesPage extends StatefulWidget {
  @override
  _CreateExpensesPageState createState() => _CreateExpensesPageState();
}

class _CreateExpensesPageState extends State<CreateExpensesPage> {
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController debtorNameController = TextEditingController();

  String selectedStock = '';
  String selectedMaterial = '';
  bool onCredit = false;
  List<Map<String, dynamic>> stocks = [];
  List<Map<String, dynamic>> materials = [];
  double availableQuantity = 0;
  bool isQuantityValid = true;

  @override
  void initState() {
    super.initState();
    _fetchStocks();
    quantityController.addListener(_validateQuantity);
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
        print('Ошибка при получении склада: ${response.body}');
      }
    } catch (e) {
      print('Исключение при получении склада: $e');
    }
  }

  Future<void> _fetchMaterialsByStock(String stockId) async {
    try {
      final response = await http.get(
        Uri.parse('http://progressim.pythonanywhere.com/api/materials/by_stock/$stockId/'),
        headers: {'Accept-Charset': 'UTF-8'},
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          materials = List<Map<String, dynamic>>.from(decodedData);
        });
      } else {
        print('Ошибка при загрузке материалов: ${response.body}');
      }
    } catch (e) {
      print('Исключение при получении материалов: $e');
    }
  }

  Future<void> _fetchAvailableQuantity(String stockId, String materialId) async {
    try {
      final response = await http.get(
        Uri.parse('http://progressim.pythonanywhere.com/api/stock_materials/$stockId/$materialId/'),
        headers: {'Accept-Charset': 'UTF-8'},
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          availableQuantity = decodedData['quantity'];
        });
      } else {
        print('Ошибка при получении доступного количества: ${response.body}');
      }
    } catch (e) {
      print('Исключение при получении доступного количества: $e');
    }
  }

  void _validateQuantity() {
    double quantity = double.tryParse(quantityController.text.replaceAll(' ', '')) ?? 0;
    setState(() {
      isQuantityValid = quantity <= availableQuantity;
    });
  }

  void _createExpense() async {
    if (selectedStock.isEmpty || selectedMaterial.isEmpty || quantityController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Все обязательные поля должны быть заполнены')),
      );
      return;
    }

    double quantity = double.parse(quantityController.text.replaceAll(' ', ''));
    if (quantity > availableQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Недостаточно материала на складе', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String url = 'http://progressim.pythonanywhere.com/api/expenses/';
    final Map<String, dynamic> body = {
      'stock': int.parse(selectedStock),
      'material': int.parse(selectedMaterial),
      'quantity': quantity,
      'price': double.parse(priceController.text.replaceAll(' ', '')),
      'on_credit': onCredit,
      'debtor_name': debtorNameController.text,
      'expenses_date': DateTime.now().toIso8601String(),
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
            content: Text('Расход успешно создан', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          quantityController.clear();
          priceController.clear();
          debtorNameController.clear();
          selectedStock = '';
          selectedMaterial = '';
          availableQuantity = 0;
          onCredit = false;
          isQuantityValid = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при создании расхода: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Исключение при создании расхода: $e')),
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
        title: Text('Создание Расхода', style: TextStyle(color: Colors.white)),
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
                  selectedMaterial = '';
                  materials = [];
                  availableQuantity = 0;
                  isQuantityValid = true;
                });
                if (value != null && value.isNotEmpty) {
                  _fetchMaterialsByStock(value);
                }
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
                  availableQuantity = 0;
                  isQuantityValid = true;
                });
                if (value != null && value.isNotEmpty && selectedStock.isNotEmpty) {
                  _fetchAvailableQuantity(selectedStock, value);
                }
              },
              value: selectedMaterial.isNotEmpty ? selectedMaterial : null,
            ),
            SizedBox(height: 20),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Количество (доступно: $availableQuantity)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: isQuantityValid ? Colors.green : Colors.red),
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
            SwitchListTile(
              title: Text('В долг'),
              value: onCredit,
              onChanged: (value) {
                setState(() {
                  onCredit = value;
                });
              },
            ),
            if (onCredit) ...[
              SizedBox(height: 20),
              TextField(
                controller: debtorNameController,
                decoration: InputDecoration(
                  labelText: 'Имя должника',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createExpense,
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
