import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

      for (int i = 0; i < kids.length; i++) {
        final response = await http.get(
          Uri.parse(
            'https://hacker-news.firebaseio.com/v0/item/${kids[i]}.json',
          ),
        );

        final commentData = jsonDecode(response.body);

        if (commentData != null &&
            commentData['deleted'] != true &&
            commentData['dead'] != true) {
          comments.add(commentData);
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
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

  String getDomain(String? url) {
    if (url == null || url.isEmpty) {
      return 'No external link';
    }

    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (e) {
      return 'Invalid URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? articleUrl = widget.story['url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6EF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6600),

        elevation: 0,

        title: const Text(
          'Story Details',

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.story['title'] ?? 'No Title',

                    style: const TextStyle(
                      fontSize: 26,

                      fontWeight: FontWeight.bold,

                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    getDomain(articleUrl),

                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Column(
                            children: [
                              const Text(
                                'Author',

                                style: TextStyle(
                                  color: Colors.grey,

                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                widget.story['by'] ?? 'Unknown',

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Column(
                            children: [
                              const Text(
                                'Score',

                                style: TextStyle(
                                  color: Colors.grey,

                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${widget.story['score'] ?? 0}',

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),

                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: Column(
                            children: [
                              const Text(
                                'Comments',

                                style: TextStyle(
                                  color: Colors.grey,

                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${widget.story['descendants'] ?? 0}',

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (articleUrl != null)
                    Column(
                      children: [
                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                'External Link',

                                style: TextStyle(
                                  fontWeight: FontWeight.bold,

                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              SelectableText(
                                articleUrl,

                                style: const TextStyle(
                                  color: Colors.blue,

                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  if (widget.story['text'] != null)
                    Column(
                      children: [
                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F8F8),

                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Text(
                            cleanHtml(widget.story['text']),

                            style: const TextStyle(fontSize: 15, height: 1.6),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Comments',

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),

                  child: CircularProgressIndicator(color: Color(0xFFFF6600)),
                ),
              )
            else if (comments.isEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Text('No comments available.'),
              )
            else
              ListView.builder(
                itemCount: comments.length,

                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                itemBuilder: (context, index) {
                  final comment = comments[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),

                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(16),
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

                        const SizedBox(height: 10),

                        Text(
                          cleanHtml(comment['text'] ?? 'No Comment'),

                          style: const TextStyle(fontSize: 14, height: 1.6),
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
