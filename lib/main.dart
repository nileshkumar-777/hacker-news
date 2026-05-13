import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HackerNewsScreen(),
    ),
  );
}

class HackerNewsScreen extends StatefulWidget {
  const HackerNewsScreen({super.key});

  @override
  State<HackerNewsScreen> createState() => _HackerNewsScreenState();
}

class _HackerNewsScreenState extends State<HackerNewsScreen> {
  List<dynamic> topStoryIds = [];
  List<dynamic> stories = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTopStories();
  }

  Future<void> fetchTopStories() async {
    try {
      final response = await http.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'),
      );

      topStoryIds = jsonDecode(response.body);

      for (int i = 0; i < 20; i++) {
        final storyResponse = await http.get(
          Uri.parse(
            'https://hacker-news.firebaseio.com/v0/item/${topStoryIds[i]}.json',
          ),
        );

        final storyData = jsonDecode(storyResponse.body);

        stories.add(storyData);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String extractDomain(String url) {
    if (url.isEmpty) {
      return "news.ycombinator.com";
    }

    try {
      Uri uri = Uri.parse(url);

      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return "unknown.com";
    }
  }

  @override
  Widget build(BuildContext context) {
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

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6600)),
            )
          : ListView.separated(
              itemCount: stories.length,

              separatorBuilder: (context, index) {
                return const Divider(height: 1, color: Color(0xFFE0E0E0));
              },

              itemBuilder: (context, index) {
                final story = stories[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(story: story),
                      ),
                    );
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),

                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,

                          child: Text(
                            '${index + 1}.',
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
                                    TextSpan(
                                      text: story['title'] ?? 'No Title',
                                    ),

                                    TextSpan(
                                      text:
                                          ' (${extractDomain(story['url'] ?? '')})',

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
                                    '${story['score'] ?? 0} points by ${story['by'] ?? 'Unknown'}',

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
                                    '${story['descendants'] ?? 0} comments',

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
              },
            ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> story;

  const DetailScreen({super.key, required this.story});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<dynamic> comments = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      final kids = widget.story['kids'];

      if (kids == null || kids.isEmpty) {
        setState(() {
          isLoading = false;
        });

        return;
      }

      for (int i = 0; i < kids.length && i < 20; i++) {
        final response = await http.get(
          Uri.parse(
            'https://hacker-news.firebaseio.com/v0/item/${kids[i]}.json',
          ),
        );

        final commentData = jsonDecode(response.body);

        comments.add(commentData);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6EF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),

        title: const Text(
          'Story Details',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.story['title'] ?? 'No Title',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text('Author: ${widget.story['by'] ?? 'Unknown'}'),

            const SizedBox(height: 6),

            Text('Score: ${widget.story['score'] ?? 0}'),

            const SizedBox(height: 6),

            Text('Comments: ${widget.story['descendants'] ?? 0}'),

            const SizedBox(height: 30),

            const Text(
              'Comments',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6600)),
                  )
                : comments.isEmpty
                ? const Text('No comments available')
                : ListView.builder(
                    itemCount: comments.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemBuilder: (context, index) {
                      final comment = comments[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),

                        padding: const EdgeInsets.all(12),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(10),

                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              comment['by'] ?? 'Unknown',

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF6600),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              (comment['text'] ?? 'No Comment')
                                  .replaceAll('<p>', '\n\n')
                                  .replaceAll('</p>', '')
                                  .replaceAll('&#x27;', "'")
                                  .replaceAll('&quot;', '"'),

                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
