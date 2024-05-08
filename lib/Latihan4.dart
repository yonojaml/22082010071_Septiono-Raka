import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SelectedCountry(),
      child: MyApp(),
    ),
  );
}

class University {
  final String name;
  final String website;

  University({required this.name, required this.website});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'] ?? '', // Mendapatkan nama universitas dari JSON
      website: json['web_pages'] != null && json['web_pages'].length > 0
          ? json['web_pages'][0]
          : '', // Mendapatkan situs web universitas dari JSON
    );
  }
}

class SelectedCountry with ChangeNotifier {
  String _country = 'Indonesia'; // Negara default

  String get country => _country; // Mendapatkan nilai negara

  set country(String newCountry) {
    _country = newCountry; // Mengatur nilai negara baru
    notifyListeners(); // Memberi tahu listener tentang perubahan nilai
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<University>> futureUniversities; // Future untuk menyimpan daftar universitas

  @override
  void initState() {
    super.initState();
    final selectedCountry = Provider.of<SelectedCountry>(context, listen: false); // Mengambil negara terpilih
    futureUniversities = fetchUniversities(selectedCountry.country); // Memuat universitas dari negara terpilih
  }

  Future<List<University>> fetchUniversities(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country')); // Memuat data universitas dari API

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => University.fromJson(json)).toList(); // Mengonversi data JSON menjadi daftar objek University
    } else {
      throw Exception('Failed to load universities');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menampilkan Universitas dan situs',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Menampilkan Universitas dan situs'),
        ),
        body: Center(
          child: Column(
            children: [
              Consumer<SelectedCountry>(
                builder: (context, selectedCountry, child) {
                  return DropdownButton<String>(
                    value: selectedCountry.country,
                    onChanged: (newValue) {
                      selectedCountry.country = newValue!; // Mengubah negara terpilih ketika dipilih dari DropdownButton
                      setState(() {
                        futureUniversities = fetchUniversities(newValue); // Memuat universitas baru ketika negara berubah
                      });
                    },
                    items: <String>[
                      'Indonesia',
                      'Malaysia',
                      'Singapura',
                      'Vietnam',
                      'Thailand',
                      'Brunei',
                      'Kamboja',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  );
                },
              ),
              Expanded(
                child: FutureBuilder<List<University>>(
                  future: futureUniversities,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Menampilkan indikator loading ketika data sedang dimuat
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}'); // Menampilkan pesan error jika gagal memuat data
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(snapshot.data![index].name), // Menampilkan nama universitas
                                Text(snapshot.data![index].website), // Menampilkan situs web universitas
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return Text('No data available'); // Menampilkan pesan jika tidak ada data yang tersedia
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
