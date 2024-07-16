import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateMaterialPage extends StatefulWidget {
  @override
  _CreateMaterialPageState createState() => _CreateMaterialPageState();
}

class _CreateMaterialPageState extends State<CreateMaterialPage> {
  final TextEditingController nameController = TextEditingController();
  String selectedUnit = 'кг';
  final List<String> unitOptions = ['кг', 'шт', 'мт'];

  Future<void> createMaterial() async {
    final url = Uri.parse('http://progressim.pythonanywhere.com/api/add-materials/');
    final response = await http.post(
      url,
      body: {
        'name': nameController.text,
        'unit': selectedUnit,
      },
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Материал успешно добавлен'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Не удалось добавить материал.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Добавить материал',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Название материала',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[850]!, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedUnit,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue!;
                });
              },
              items: unitOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: createMaterial,
                  child: Text('Создать'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.grey[850]),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
