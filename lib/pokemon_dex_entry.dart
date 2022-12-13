import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonEntry extends StatelessWidget {
  final String dexUrl;
  final String name;

  PokemonEntry({required this.dexUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worldex',
      home: Scaffold(
          appBar: AppBar(
            title: nameWidget(),
            automaticallyImplyLeading: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () { Navigator.pop(context, false); },),
          ),
          body: Column(children: [
            SizedBox(
              child: FutureBuilder<List<String>>(
                future: getTypeImages(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<String> images = [];
                    for (int i = 0; i < snapshot.data!.length; i++) {
                      images.add(snapshot.data![i]);
                    }
                    if (images.length == 2) {
                      return Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                type(),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image(
                                      image: AssetImage(images[0]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image(
                                      image: AssetImage(images[1]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 6),
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                type(),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: Image(
                                      image: AssetImage(images[0]),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("error"));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SizedBox(
              height: 270,
              child: FutureBuilder<List<String>>(
                future: createImageList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return PageView.builder(
                        padEnds: true,
                        itemCount: snapshot.data!.length,
                        pageSnapping: true,
                        itemBuilder: (context, pagePosition) {
                          return Container(
                            margin: const EdgeInsets.only(
                                left: 10, right: 10, bottom: 10, top: 4),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.blue, width: 10.0),
                              color: Colors.lightBlueAccent,
                            ),
                            height: 200,
                            width: 200,
                            child: Image.network(
                              snapshot.data![pagePosition],
                              fit: BoxFit.contain,
                            ),
                          );
                        });
                  } else if (snapshot.hasError) {
                    return const Center(child: Text("error"));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 15),
              alignment: Alignment.center,
              child: FutureBuilder<String>(
                    future: getDescription(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.lightBlueAccent,
                          ),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
          ])),
    );
  }

  Widget nameWidget() {
    String name = this.name[0].toUpperCase() + this.name.substring(1);
    int charIndex;
    if (name.contains("-")) {
      charIndex = name.indexOf("-");
      name = name.substring(0, charIndex);
    }
    return Text(name);
  }

  Future<List<String>> createImageList() async {
    final response = await http.get(Uri.parse(dexUrl));
    final map = json.decode(response.body);
    String back;
    String front;
    String backShiny;
    String frontShiny;
    List<String> spriteImages = [];

    if (map["sprites"]["front_default"] != null) {
      front = map["sprites"]["front_default"];
      spriteImages.add(front);
    }
    if (map["sprites"]["back_default"] != null) {
      back = map["sprites"]["back_default"];
      spriteImages.add(back);
    }
    if (map["sprites"]["front_shiny"] != null) {
      frontShiny = map["sprites"]["front_shiny"];
      spriteImages.add(frontShiny);
    }
    if (map["sprites"]["back_shiny"] != null) {
      backShiny = map["sprites"]["back_shiny"];
      spriteImages.add(backShiny);
    }
    return spriteImages;
  }

  Future<List<String>> getTypeImages() async {
    final response = await http.get(Uri.parse(dexUrl));
    final map = json.decode(response.body);

    List<dynamic> types = map["types"];
    List<String> typeImages = [];
    for (var map in types) {
      typeImages.add(map["type"]["name"] + '.png');
    }

    return typeImages;
  }

  Future<String> getDescription() async {
    final response = await http
        .get(Uri.parse("https://pokeapi.co/api/v2/pokemon-species/" + name));
    final map = json.decode(response.body);
    String description = "";

    int place = 7;
    while (true) {
      if (map["flavor_text_entries"][place]["flavor_text"] != null &&
          map["flavor_text_entries"][place]["language"]["name"] == "en") {
        description = map["flavor_text_entries"][place]["flavor_text"].replaceAll(RegExp("\\\\.|[\t\n\f]"), " ");
        break;
      }
      place++;
    }

    return description;
  }


  Widget type() {
    return const Text(
      "Type: ",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 30,
        color: Colors.lightBlueAccent,
      ),
    );
  }
}
