import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Todo {
  const Todo(this.id, this.title, this.completed);

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
    json['id'] as int,
    json['title'] as String,
    json['completed'] as bool,
  );

  final int id;
  final String title;
  final bool completed;
}

class TodoApi {
  TodoApi({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _base =
          baseUri ??
          Uri.parse(
            const String.fromEnvironment(
              'TODO_API_URL',
              defaultValue: kIsWeb
                  ? 'http://127.0.0.1:8787'
                  : 'http://10.0.2.2:8787',
            ),
          );

  final http.Client _client;
  final Uri _base;
  static const _headers = {'content-type': 'application/json; charset=utf-8'};

  Uri _url([int? id]) => _base.resolve(id == null ? '/todos' : '/todos/$id');

  Future<http.Response> _expect(
    Future<http.Response> request,
    int status,
  ) async {
    final response = await request.timeout(const Duration(seconds: 8));
    if (response.statusCode != status) {
      throw StateError(
        'Expected HTTP $status, received ${response.statusCode}',
      );
    }
    return response;
  }

  Future<List<Todo>> readAll() async {
    final response = await _expect(_client.get(_url()), 200);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((item) => Todo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> create(String title) async {
    await _expect(
      _client.post(
        _url(),
        headers: _headers,
        body: jsonEncode({'title': title}),
      ),
      201,
    );
  }

  Future<void> update(Todo todo, {String? title, bool? completed}) async {
    await _expect(
      _client.put(
        _url(todo.id),
        headers: _headers,
        body: jsonEncode({
          'title': title ?? todo.title,
          'completed': completed ?? todo.completed,
        }),
      ),
      200,
    );
  }

  Future<void> delete(int id) async {
    await _expect(_client.delete(_url(id)), 204);
  }

  void close() => _client.close();
}
