import 'package:flutter/material.dart';
import 'package:hacker_news/screens/home_screen.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HackerNewsScreen(),
    ),
  );
}
