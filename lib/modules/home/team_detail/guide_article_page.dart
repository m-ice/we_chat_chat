import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/guide_article.dart';

class GuideArticlePage extends StatelessWidget {
  const GuideArticlePage({super.key, required this.article});
  final GuideArticle article;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('guide_article_title'.tr)),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          article.title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          'guide_read_minutes'.trParams({'minutes': '${article.readMinutes}'}),
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 18),
        Text(
          article.summary,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Text(article.body, style: const TextStyle(fontSize: 16, height: 1.8)),
      ],
    ),
  );
}
