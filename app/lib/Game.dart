// ignore_for_file: prefer_const_constructors

import 'package:app/animals/a_level1.dart';
import 'package:app/fruits/f_level1.dart';
import 'package:app/vegetables/v_level1.dart';
import 'package:app/vehicles/ve_level1.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Text(
          'Categories',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 59, 193, 64),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10),
        children: [
          buildGridItem(
              context, 'assets/images/fruit.jpg', 'Fruits', FLevel1()),
          buildGridItem(
              context, 'assets/images/vegetable.jpg', 'Vegetables', VLevel1()),
          buildGridItem(
              context, 'assets/images/vehicle.jpg', 'Vehicles', HLevel1()),
          buildGridItem(
              context, 'assets/images/animal.jpg', 'Animals', ALevel1()),
        ],
      ),
    );
  }

  Widget buildGridItem(
      BuildContext context, String imagePath, String text, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              backgroundColor: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
