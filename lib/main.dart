import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HackerNewsScreen(),
    );
  }
}

class HackerNewsScreen extends StatelessWidget {
  const HackerNewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> stories = [
      {
        "title": "Crew-9 Returns to Earth",
        "domain": "spacex.com",
        "points": "198",
        "author": "saikatsg",
        "comments": "130",
      },
      {
        "title": "The Internet Slum",
        "domain": "abandonying.com",
        "points": "36",
        "author": "kiwi",
        "comments": "24",
      },
      {
        "title": "Two new PebbleOS watches",
        "domain": "github.com",
        "points": "1322",
        "author": "griffin",
        "comments": "405",
      },
      {
        "title": "Make Ubuntu packages faster",
        "domain": "ubuntu.com",
        "points": "473",
        "author": "jeff",
        "comments": "224",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),
        elevation: 0,
        titleSpacing: 0,
        leading: const Icon(Icons.newspaper, color: Colors.white),
        title: const Text(
          'Hacker News',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        itemCount: stories.length,
        separatorBuilder: (context, index) {
          return const Divider(height: 1, color: Color(0xFFE0E0E0));
        },
        itemBuilder: (context, index) {
          final story = stories[index];

          return NewsItemTile(
            index: index + 1,
            title: story["title"] ?? "",
            domain: story["domain"] ?? "",
            points: story["points"] ?? "",
            author: story["author"] ?? "",
            comments: story["comments"] ?? "",
          );
        },
      ),
    );
  }
}

class NewsItemTile extends StatelessWidget {
  final int index;
  final String title;
  final String domain;
  final String points;
  final String author;
  final String comments;

  const NewsItemTile({
    super.key,
    required this.index,
    required this.title,
    required this.domain,
    required this.points,
    required this.author,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$index.',
                style: const TextStyle(
                  color: Color(0xFF828282),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(text: title),
                        TextSpan(
                          text: ' ($domain)',
                          style: const TextStyle(
                            color: Color(0xFF828282),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    children: [
                      Text(
                        '$points points by $author',
                        style: const TextStyle(
                          color: Color(0xFF828282),
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        ' | ',
                        style: TextStyle(color: Color(0xFF828282)),
                      ),
                      Text(
                        '$comments comments',
                        style: const TextStyle(
                          color: Color(0xFFFF6600),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
