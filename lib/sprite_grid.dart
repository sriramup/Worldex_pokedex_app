import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/pokemon_dex_entry.dart';
import 'dart:convert';
import 'SearchWidget.dart';
import 'master_list.dart';

class SpriteGrid extends StatefulWidget {
  final List<MasterListPokemon> masterList;

  const SpriteGrid(this.masterList, {Key? key}) : super(key: key);

  @override
  State<SpriteGrid> createState() => _SpriteGridState();
}

class _SpriteGridState extends State<SpriteGrid> {
  var query = '';

  List<MasterListPokemon> searchList = [];

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'Search',
        onChanged: searchSprite,
      );

  @override
  void initState() {
    super.initState();
    searchList = widget.masterList;
  }

  void searchSprite(String query) {
    final sprites = widget.masterList.where((pokemon) {
      final searchLower = query.toLowerCase();
      final nameLower = pokemon.name.toLowerCase();

      return nameLower.startsWith(searchLower);
    }).toList();

    setState(() {
      this.query = query;
      searchList = sprites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: buildSearch(),
          ),
          Expanded(
            flex: 9,
            child: reloadSearch(searchList),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> getPokeJson(String jsonUrl) async {
    final response = await http.get(Uri.parse(jsonUrl));
    final map = json.decode(response.body);
    return map;
  }

  Widget reloadSearch(List<MasterListPokemon> list) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: list.length ~/ 1,
      itemBuilder: (context, index) {
        int startIndex = index * 4;
        int endIndex = startIndex + 4;
        if (endIndex >= list.length) endIndex = list.length;
        List<Widget> cards = [];
        for (int i = startIndex; i < endIndex; i++) {
          cards.add(
            FutureBuilder<Map<String, dynamic>>(
              future: getPokeJson(list[i].infoUrl),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final pokeMap = snapshot.data!;
                  return InkWell(
                      onTap: () {
                        onTap(pokeMap);
                      },
                      child:
                          Image.network(pokeMap["sprites"]["front_default"]));
                } else {
                  return const SizedBox(
                    height: 96,
                    width: 96,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
          );
        }
        return Row(
          children: cards,
        );
      },
    );
  }

  void onTap(Map<String, dynamic> pokeMap) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonEntry(
            dexUrl: pokeMap["pokemon"]["url"],
            name: pokeMap["pokemon"]["name"]),
      ),
    );
  }
}
