import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  final String baseUrl = 'newsapi.org';
  final String apiKey = '8bb19f6e3bbc4390b99ac8a53f58c98c'; // YOUR NEWS API KEY

  Future<List<Article>> fetchNewsArticles() async {
    final uri = Uri.https(
      baseUrl,
      '/v2/top-headlines',
      {
        'country': 'us',
        'apiKey': apiKey,
      },
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final List<dynamic> articlesJson = jsonData['articles'];
        return articlesJson
            .map((json) => Article.fromJson(json))
            .toList();
      } else {
        throw HttpException('Server returned ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on FormatException {
      throw Exception('Invalid JSON format');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}