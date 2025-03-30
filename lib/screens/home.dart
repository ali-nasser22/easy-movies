import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import '../api/apikey.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> trendingList = [];

  Future<void> trendingListHome() async {
    trendingList.clear();
    if (uval == 1) {
      var treendingWeekResponse = await http.get(Uri.parse(trendingweekurl));

      if (treendingWeekResponse.statusCode == 200) {
        var tempData = jsonDecode(treendingWeekResponse.body);
        var trendingWeekJson = tempData['results'];
        for (var i = 0; i < trendingWeekJson.length; i++) {
          trendingList.add({
            'id': trendingWeekJson[i]['id'],
            'poster_path': trendingWeekJson[i]['poster_path'],
            'vote_average': trendingWeekJson[i]['vote_average'],
            'media_type': trendingWeekJson[i]['media_type'],
            'index': i,
          });
        }
      }
    } else if (uval == 2) {
      var trendingDayResponse = await http.get(Uri.parse(trendingdayurl));
      if (trendingDayResponse.statusCode == 200) {
        var tempData = jsonDecode(trendingDayResponse.body);
        var trendingDayJson = tempData['results'];
        for (var i = 0; i < trendingDayJson.length; i++) {
          trendingList.add({
            'id': trendingDayJson[i]['id'],
            'poster_path': trendingDayJson[i]['poster_path'],
            'vote_average': trendingDayJson[i]['vote_average'],
            'media_type': trendingDayJson[i]['media_type'],
            'index': i,
          });
        }
      }
    }
  }

  int uval = 1;

  @override
  Widget build(BuildContext context) {
      TabController _tabController = TabController(length: 3, vsync: this);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: FutureBuilder(
                future: trendingListHome(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return CarouselSlider(
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        enlargeCenterPage: true,
                        enlargeFactor: 0.5,
                        height: MediaQuery.of(context).size.height,
                      ),
                      items:
                          trendingList.map((i) {
                            return GestureDetector(
                              onTap: () {},
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        'https://image.tmdb.org/t/p/w500/${i['poster_path']}',
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  }
                },
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Trending 🔥",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      dropdownColor: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                      items: [
                        DropdownMenuItem(
                          value: 1,
                          child: Text(
                            'Weekly',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 2,
                          child: Text(
                            'Daily',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                      value: uval,
                      onChanged: (value) {
                        setState(() {
                          trendingList.clear();
                          uval = int.parse(value.toString());
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Center(child: Text("Trending")),
              Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: TabBar(controller: _tabController, tabs: [
                  Tab(text: "Movies"),
                  Tab(text: "TV"),
                  Tab(text: "People"),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
