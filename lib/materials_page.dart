import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'create_material_page.dart';

class Material {
  final int id;
  final String name;
  final String unit;
  final DateTime timeCreate;

  Material({
    required this.id,
    required this.name,
    required this.unit,
    required this.timeCreate,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      timeCreate: DateTime.parse(json['time_create']).toLocal(),
    );
  }
}

Future<List<Material>> fetchMaterials() async {
  final response = await http.get(Uri.parse('http://progressim.pythonanywhere.com/api/materials/'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
    return jsonResponse.map((data) => Material.fromJson(data)).toList();
  } else {
    throw Exception('Не удалось загрузить материалы');
  }
}

Future<void> deleteMaterial(int id) async {
  final response = await http.delete(
    Uri.parse('http://progressim.pythonanywhere.com/api/materials/$id/delete/'),
  );

  if (response.statusCode != 204) {
    throw Exception('Не удалось удалить материал.');
  }
}

class MaterialsPage extends StatefulWidget {
  @override
  _MaterialsPageState createState() => _MaterialsPageState();
}

class _MaterialsPageState extends State<MaterialsPage> {
  late Future<List<Material>> futureMaterials;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    futureMaterials = fetchMaterials();
  }

  void refreshMaterials() {
    setState(() {
      futureMaterials = fetchMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Материалы',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: refreshMaterials,
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateMaterialPage()),
              );
              if (result == true) {
                refreshMaterials();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Material>>(
              future: futureMaterials,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Нет данных'));
                } else {
                  List<Material> filteredMaterials = snapshot.data!.where((material) {
                    return material.name.toLowerCase().contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredMaterials.length,
                    itemBuilder: (context, index) {
                      Material material = filteredMaterials[index];
                      String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(material.timeCreate);
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          title: Text(
                            material.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Ед-измерения: ${material.unit}\nСоздано: $formattedDate'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Подтверждение удаления'),
                                  content: Text('Вы точно хотите удалить материал?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text('Отмена'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text('Удалить'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                try {
                                  await deleteMaterial(material.id);
                                  refreshMaterials();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Материал удален'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Ошибка удаления материала'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
