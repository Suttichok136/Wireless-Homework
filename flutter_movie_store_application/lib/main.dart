import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Store',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final CategoriesScroller categoriesScroller = CategoriesScroller();
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;
  double totalPrice = 0;
  int save = 0;
  List<int> order = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  String name;

  List<Widget> itemsData = [];

  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  void getPostsData() {
    List<dynamic> responseList = MOVIE;
    List<Widget> listItems = [];
    responseList.forEach((post) {
      listItems.add(Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post["name"],
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "\$ ${post["price"]}",
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    ButtonTheme(
                        height: 5,
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              totalPrice += post["price"];
                              totalPrice = roundDouble(totalPrice, 2);
                              print(totalPrice);
                            });
                            print(responseList.indexOf(post));
                            order[responseList.indexOf(post)]++;
                            print(order[responseList.indexOf(post)]);
                          },
                          child: Text(
                            'Add to cart',
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          ),
                          color: Colors.blueAccent,
                        )),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    if (order[responseList.indexOf(post)] > 0) {
                      setState(() {
                        totalPrice -= post["price"];
                        totalPrice = roundDouble(totalPrice, 2);
                        if (totalPrice <= 0) {
                          totalPrice = 0;
                        }
                      });
                      order[responseList.indexOf(post)]--;
                      if (order[responseList.indexOf(post)] < 0) {
                        order[responseList.indexOf(post)] = 0;
                      }
                    }
                  },
                  icon: Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                  alignment: Alignment.bottomCenter,
                ),
                Image.asset(
                  "assets/images/${post["image"]}",
                  height: double.infinity,
                )
              ],
            ),
          )));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    super.initState();
    getPostsData();
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    //final double categoryHeight = size.height * 0.30;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: Icon(
            Icons.menu,
            color: Colors.black,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.person, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
        body: Container(
          height: size.height,
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    "Menu",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  Text(
                    "Total Price = \$ $totalPrice",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        totalPrice = 0;
                        for (int i = 0; i < order.length; i++) {
                          order[i] = 0;
                        }
                      });
                    },
                    child: Text(
                      'Clear order',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    color: Colors.redAccent,
                  )
                ],
              ),
              Expanded(
                  child: ListView.builder(
                      controller: controller,
                      itemCount: itemsData.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        if (topContainer > 0.5) {
                          scale = index + 0.5 - topContainer;
                          if (scale < 0) {
                            scale = 0;
                          } else if (scale > 1) {
                            scale = 1;
                          }
                        }
                        return Opacity(
                          opacity: scale,
                          child: Transform(
                            transform: Matrix4.identity()..scale(scale, scale),
                            alignment: Alignment.bottomCenter,
                            child: Align(
                                heightFactor: 0.7,
                                alignment: Alignment.topCenter,
                                child: itemsData[index]),
                          ),
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
