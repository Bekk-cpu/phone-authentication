import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('damn it!!!, Finally', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), ),),
    );
  }
}
