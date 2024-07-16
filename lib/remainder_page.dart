import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';

class RemainderPage extends StatefulWidget {
  @override
  _RemainderPageState createState() => _RemainderPageState();
}

class _RemainderPageState extends State<RemainderPage> {
  List<dynamic> stockMaterials = [];
  List<dynamic> stocks = [];
  bool isLoading = false;
  String? selectedStockId;

  @override
  void initState() {
    super.initState();
    fetchStocks();
  }

  Future<void> fetchStocks() async {
    final response = await http.get(Uri.parse('http://progressim.pythonanywhere.com/api/stock/'));
    if (response.statusCode == 200) {
      setState(() {
        stocks = json.decode(utf8.decode(response.bodyBytes));
      });
    } else {
      throw Exception('Не удалось загрузить склады');
    }
  }

  Future<void> fetchStockMaterials(String? stockId) async {
    if (stockId == null) return;
    setState(() {
      isLoading = true;
    });
    final url = 'http://progressim.pythonanywhere.com/api/stockmaterials/?stock_id=$stockId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        stockMaterials = json
            .decode(utf8.decode(response.bodyBytes))
            .where((material) => material['quantity'] != null && material['quantity'] > 0)
            .toList();
        isLoading = false;
      });
    } else {
      throw Exception('Не удалось загрузить материалы на складе.');
    }
  }

  void _onStockChanged(String? stockId) {
    setState(() {
      selectedStockId = stockId;
      stockMaterials = [];
    });
    fetchStockMaterials(stockId);
  }

  void _refreshData() {
    fetchStocks();
    if (selectedStockId != null) {
      fetchStockMaterials(selectedStockId);
    }
  }

  Color _getCardColor(int quantity) {
    if (quantity <= 100) {
      return Colors.redAccent;
    } else if (quantity > 200 && quantity <= 450) {
      return Colors.yellowAccent;
    } else if (quantity >= 450) {
      return Colors.greenAccent;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Остаток',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                value: selectedStockId,
                hint: Text('Выберите склад'),
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 300,
                  width: MediaQuery.of(context).size.width - 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  offset: const Offset(0, -5),
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(40),
                    thickness: MaterialStateProperty.all(6),
                    thumbVisibility: MaterialStateProperty.all(true),
                  ),
                ),
                items: stocks.map<DropdownMenuItem<String>>((stock) {
                  return DropdownMenuItem<String>(
                    value: stock['id'].toString(),
                    child: Row(
                      children: [
                        Icon(Icons.warehouse, color: Colors.blueGrey[900]),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            stock['name_stock'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _onStockChanged,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: selectedStockId == null
                  ? Center(
                child: Text(
                  'Пожалуйста, выберите склад для просмотра данных.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : isLoading
                  ? Center(child: CircularProgressIndicator())
                  : stockMaterials.isEmpty
                  ? Center(child: Text('В этом складе нет материалов'))
                  : ListView.builder(
                itemCount: stockMaterials.length,
                itemBuilder: (context, index) {
                  final stockMaterial = stockMaterials[index];
                  final quantity = stockMaterial['quantity'];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: _getCardColor(quantity is int ? quantity : quantity.toInt()),
                    child: ListTile(
                      leading: Icon(Icons.inventory, color: Colors.white),
                      title: Text(
                        stockMaterial['material_name'],
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Количество: $quantity ${stockMaterial['material_unit']}',
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Средняя цена: ${stockMaterial['avg_price']}',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
