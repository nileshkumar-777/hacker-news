import 'dart:convert';
import 'package:hacker_news/screens/detail_screen.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timeago/timeago.dart' as timeago;

class HackerNewsScreen extends StatefulWidget {
  const HackerNewsScreen({super.key});

  @override
  State<HackerNewsScreen> createState() => _HackerNewsScreenState();
}

class _HackerNewsScreenState extends State<HackerNewsScreen> {
  List<dynamic> topStoryIds = [];
  List<dynamic> stories = [];

  final ScrollController _scrollController = ScrollController();

  bool isLoading = true;
  bool isFetchingMore = false;

  int currentIndex = 0;

  static const int batchSize = 20;

  @override
  void initState() {
    super.initState();

    fetchTopStories();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !isFetchingMore) {
        loadMoreStories();
      }
    });
  }

  Future<void> fetchTopStories() async {
    try {
      final response = await http.get(
        Uri.parse('https://hacker-news.firebaseio.com/v0/topstories.json'),
      );

      topStoryIds = jsonDecode(response.body);

      await loadMoreStories();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadMoreStories() async {
    if (isFetchingMore) return;

    isFetchingMore = true;

    int endIndex = currentIndex + batchSize;

    if (endIndex > topStoryIds.length) {
      endIndex = topStoryIds.length;
    }

    for (int i = currentIndex; i < endIndex; i++) {
      final storyResponse = await http.get(
        Uri.parse(
          'https://hacker-news.firebaseio.com/v0/item/${topStoryIds[i]}.json',
        ),
      );

      if (storyResponse.statusCode == 200) {
        final storyData = jsonDecode(storyResponse.body);

        if (storyData != null) {
          stories.add(storyData);
        }
      }
    }

    currentIndex = endIndex;

    isFetchingMore = false;

    if (!mounted) return;

    setState(() {});
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

  String getTimeAgo(int unixTime) {
    final date = DateTime.fromMillisecondsSinceEpoch(unixTime * 1000);

    return timeago.format(date);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          : RefreshIndicator(
              color: const Color(0xFFFF6600),

              onRefresh: () async {
                stories.clear();
                topStoryIds.clear();

                currentIndex = 0;

                isLoading = true;
                isFetchingMore = false;

                setState(() {});

                await fetchTopStories();
              },

              child: ListView.separated(
                controller: _scrollController,

                itemCount: stories.length + 1,

                separatorBuilder: (context, index) {
                  return const Divider(height: 1, color: Color(0xFFE0E0E0));
                },

                itemBuilder: (context, index) {
                  if (index == stories.length) {
                    return currentIndex >= topStoryIds.length
                        ? const SizedBox()
                        : const Padding(
                            padding: EdgeInsets.all(20),

                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF6600),
                              ),
                            ),
                          );
                  }

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
                                      '${story['score'] ?? 0} points by ${story['by'] ?? 'Unknown'} • ${getTimeAgo(story['time'] ?? 0)}',

                                      style: const TextStyle(
                                        color: Color(0xFF828282),

                                        fontSize: 12,
                                      ),
                                    ),

                                    const Text(
                                      ' | ',

                                      style: TextStyle(
                                        color: Color(0xFF828282),
                                      ),
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
            ),
    );
  }
}
