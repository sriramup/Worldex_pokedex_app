import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pokedex/sprite_grid.dart';
import 'package:http/http.dart' as http;
import 'master_list.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BasePage();
  }
}

class BasePage extends StatelessWidget {
  const BasePage({Key? key}) : super(key: key);

  Future<List<MasterListPokemon>> createMasterList() async {
    List<MasterListPokemon> masterList = [];

    final response = await http.get(Uri.parse(
        "https://pokeapi.co/api/v2/pokemon-form/?limit=898&offset=0"));
    final map = json.decode(response.body);

    for (int i = 0; i < 898; i++) {
      String name = map["results"][i]["name"];
      String infoUrl = map["results"][i]["url"];
      MasterListPokemon entry = MasterListPokemon(name: name, infoUrl: infoUrl);
      masterList.add(entry);
    }

    return masterList;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worldex',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Worldex'),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: FutureBuilder<List<MasterListPokemon>>(
            future: createMasterList(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SpriteGrid(snapshot.data!);
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(child: Text("bruh error"));
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}
