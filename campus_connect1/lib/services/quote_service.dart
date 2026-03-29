import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote.dart';


class QuoteService {
  final String _apiUrl = 'https://api.api-ninjas.com/v1/quotes';
  final String _apiKey = 'MWvtxjiX4pmN1sptOwlJX7TOYLS7lCLGu3o71C86';


  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'X-Api-Key': _apiKey},
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return Quote.fromJson(data[0]);
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      rethrow;
    }
  }
}