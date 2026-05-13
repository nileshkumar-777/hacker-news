import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> openArticle() async {
    final url = widget.story['url'];

    if (url == null) return;

    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String cleanHtml(String text) {
    return text
        .replaceAll('<p>', '\n\n')
        .replaceAll('</p>', '')
        .replaceAll('&#x27;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<');
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

            const SizedBox(height: 14),

            Wrap(
              spacing: 10,
              runSpacing: 8,

              children: [
                Text(
                  'Author: ${widget.story['by'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 15),
                ),

                Text(
                  'Score: ${widget.story['score'] ?? 0}',
                  style: const TextStyle(fontSize: 15),
                ),

                Text(
                  'Comments: ${widget.story['descendants'] ?? 0}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (widget.story['url'] != null)
              GestureDetector(
                onTap: openArticle,

                child: Text(
                  widget.story['url'],

                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(10),

                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: const Text(
                  'This story does not contain an external article link.',

                  style: TextStyle(fontSize: 15),
                ),
              ),

            const SizedBox(height: 20),

            if (widget.story['text'] != null)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(10),

                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: Text(
                  cleanHtml(widget.story['text']),

                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),

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
                              cleanHtml(comment['text'] ?? 'No Comment'),

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
