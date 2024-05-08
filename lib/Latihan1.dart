import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
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

class CountryCubit extends Cubit<String> {
  CountryCubit() : super('Indonesia'); // Negara default

  void selectCountry(String newCountry) => emit(newCountry); // Memilih negara baru dan memperbarui state
}

class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]); // Inisialisasi state dengan list kosong

  Future<void> fetchUniversities(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country')); // Memuat data universitas dari API

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      emit(data.map((json) => University.fromJson(json)).toList()); // Memperbarui state dengan daftar universitas
    } else {
      throw Exception('Failed to load universities'); // Melemparkan exception jika gagal memuat data
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CountryCubit>(create: (context) => CountryCubit()), // Membuat provider untuk CountryCubit
        BlocProvider<UniversityCubit>(create: (context) => UniversityCubit()), // Membuat provider untuk UniversityCubit
      ],
      child: MaterialApp(
        title: 'Menampilkan Universitas dan situs',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Menampilkan Universitas dan situs'),
          ),
          body: Center(
            child: Column(
              children: [
                CountryDropdown(), // Widget untuk menampilkan dropdown negara
                Expanded(child: UniversityList()), // Widget untuk menampilkan daftar universitas
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CountryDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountryCubit, String>(
      builder: (context, selectedCountry) {
        return DropdownButton<String>(
          value: selectedCountry, // Nilai terpilih pada dropdown
          onChanged: (newValue) {
            context.read<CountryCubit>().selectCountry(newValue!); // Memilih negara baru
            context.read<UniversityCubit>().fetchUniversities(newValue); // Memuat universitas baru sesuai dengan negara yang dipilih
          },
          items: <String>[
            'Indonesia',
            'Malaysia',
            'Singapura',
            'Vietnam',
            'Thailand',
            'Brunei',
            'Kamboja',
            // Tambahkan negara ASEAN lainnya di sini
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      },
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityCubit, List<University>>(
      builder: (context, universityList) {
        if (universityList.isEmpty) {
          return CircularProgressIndicator(); // Menampilkan indikator loading jika daftar universitas kosong
        } else {
          return ListView.builder(
            itemCount: universityList.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(border: Border.all()),
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(universityList[index].name), // Menampilkan nama universitas
                    Text(universityList[index].website), // Menampilkan situs web universitas
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
