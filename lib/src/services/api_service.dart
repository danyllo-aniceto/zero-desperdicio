import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://suaapi.com/api';
  
  get http => null;

  Future<List<T>> fetchList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    var http;
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => fromJson(e)).toList();
    } else {
      throw Exception('Erro ao buscar dados: ${response.statusCode}');
    }
  }

  Future<T> post<T>({
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception('Erro ao enviar dados: ${response.statusCode}');
    }
  }
}
