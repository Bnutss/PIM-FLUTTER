import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _selectedFilter = 'all';
  DateTime _selectedDate = DateTime.now();

  Future<Map<String, dynamic>> fetchDailySummary() async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final response = await http.get(Uri.parse('http://progressim.pythonanywhere.com/api/daily-summary/?filter=$_selectedFilter&date=$dateStr'));

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Не удалось загрузить ежедневную сводку.');
    }
  }

  String formatCurrency(dynamic amount) {
    final format = NumberFormat.currency(locale: 'ru_RU', symbol: 'UZS', decimalDigits: 0);
    return format.format(amount is int ? amount.toDouble() : amount);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _refreshData() {
    setState(() {});
  }

  Future<void> _sendData(String type) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final url = Uri.parse('http://progressim.pythonanywhere.com/api/send-telegram/?type=$type&date=$dateStr');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Данные успешно отправлены')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка отправки данных')));
    }
  }

  void _showSendOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Выберите, что отправить'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.arrow_downward, color: Colors.green),
                title: Text('Отправить Итог прихода'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendData('comings');
                },
              ),
              ListTile(
                leading: Icon(Icons.arrow_upward, color: Colors.red),
                title: Text('Отправить Итог расхода'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendData('expenses');
                },
              ),
              ListTile(
                leading: Icon(Icons.credit_card, color: Colors.orange),
                title: Text('Отправить Итог долга'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendData('credit');
                },
              ),
              ListTile(
                leading: Icon(Icons.send, color: Colors.blue),
                title: Text('Отправить все'),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendData('all');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Итоги на конец дня',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Обновить',
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _showSendOptions,
            tooltip: 'Отправить',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                              value: 'all',
                              child: Row(
                                children: [
                                  Icon(Icons.list, color: Colors.black),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Все итоги', overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'comings',
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_downward, color: Colors.green),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Итог прихода', overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'expenses',
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_upward, color: Colors.red),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Итог расхода', overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'credit',
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Expanded(child: Text('Итог долга', overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedFilter = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[700],
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              DateFormat('dd.MM.yy').format(_selectedDate),
                              style: TextStyle(color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: fetchDailySummary(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('Нет данных'));
                } else {
                  final data = snapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_selectedFilter == 'all' || _selectedFilter == 'comings')
                            _buildSummaryCard('Приходы', data['total_comings'], Icons.arrow_downward, Colors.green),
                          if (_selectedFilter == 'all' || _selectedFilter == 'expenses')
                            _buildSummaryCard('Расходы', data['total_expenses'], Icons.arrow_upward, Colors.red),
                          if (_selectedFilter == 'all' || _selectedFilter == 'credit')
                            _buildSummaryCard('Долги', data['total_credit'], Icons.credit_card, Colors.orange),
                          SizedBox(height: 20),
                          if (_selectedFilter == 'all' || _selectedFilter == 'comings')
                            ..._buildDetailSection('Детали приходов:', data['comings'], Icons.add_shopping_cart, Colors.blue),
                          if (_selectedFilter == 'all' || _selectedFilter == 'expenses' || _selectedFilter == 'credit')
                            ..._buildDetailSection('Детали расходов:', data['expenses'], Icons.remove_shopping_cart, Colors.red),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, dynamic amount, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(formatCurrency(amount)),
      ),
    );
  }

  List<Widget> _buildDetailSection(String title, List<dynamic> items, IconData icon, Color color) {
    return [
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(height: 8),
      ...items.map<Widget>((item) => _buildDetailCard(item, icon, color)).toList(),
      SizedBox(height: 16),
    ];
  }

  Widget _buildDetailCard(dynamic item, IconData icon, Color color) {
    double quantity = double.tryParse(item['quantity'].toString()) ?? 0.0;
    double price = double.tryParse(item['price'].toString()) ?? 0.0;
    double totalAmount = quantity * price;
    String unit = item['material_unit'].toString();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['material_name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text('Количество: $quantity $unit'),
            Text('Общая сумма: ${formatCurrency(totalAmount)}'),
            if (item['debtor_name'] != null && item['debtor_name'].isNotEmpty)
              Text('Должник: ${item['debtor_name']}'),
          ],
        ),
      ),
    );
  }
}
