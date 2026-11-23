import 'dart:convert';
import 'dart:io';
import 'dart:math';

const quotes = [
  {
    'quote': 'A small experiment can answer a large question.',
    'author': 'Course Labs',
  },
  {'quote': 'Make the next step easy to see.', 'author': 'Course Labs'},
  {
    'quote': 'A clear example is a good place to start.',
    'author': 'Course Labs',
  },
];

class TodoServer {
  final _tasks = <int, Map<String, Object>>{
    1: {'id': 1, 'title': 'Try creating a task', 'completed': false},
  };
  int _nextId = 2;
  final _random = Random();

  Future<void> handle(HttpRequest request) async {
    final response = request.response;
    final origin = request.headers.value('origin');
    if (origin != null &&
        RegExp(r'^http://(localhost|127\.0\.0\.1)(:\d+)?$').hasMatch(origin)) {
      response.headers.set('access-control-allow-origin', origin);
      response.headers.set('vary', 'Origin');
      response.headers.set(
        'access-control-allow-methods',
        'GET, POST, PUT, DELETE, OPTIONS',
      );
      response.headers.set('access-control-allow-headers', 'content-type');
    }
    response.headers.contentType = ContentType.json;
    final path = request.uri.pathSegments;
    final method = request.method;

    try {
      if (method == 'OPTIONS') {
        response.statusCode = 204;
      } else if (method == 'GET' && request.uri.path == '/quotes/random') {
        _send(response, 200, quotes[_random.nextInt(quotes.length)]);
      } else if (path.length == 1 && path.first == 'todos') {
        switch (method) {
          case 'GET':
            _send(response, 200, _tasks.values.toList());
          case 'POST':
            final fields = await _readTask(request);
            final id = _nextId++;
            final task = _tasks[id] = {'id': id, ...fields};
            _send(response, 201, task);
          default:
            _send(response, 405, {'error': 'Method not allowed'});
        }
      } else if (path.length == 2 && path.first == 'todos') {
        final id = int.tryParse(path[1]);
        if (id == null || !_tasks.containsKey(id)) {
          _send(response, 404, {'error': 'Task not found'});
        } else {
          switch (method) {
            case 'GET':
              _send(response, 200, _tasks[id]);
            case 'PUT':
              final fields = await _readTask(request, updating: true);
              final task = _tasks[id];
              if (task == null) {
                _send(response, 404, {'error': 'Task not found'});
              } else {
                task.addAll(fields);
                _send(response, 200, task);
              }
            case 'DELETE':
              _tasks.remove(id);
              response.statusCode = 204;
            default:
              _send(response, 405, {'error': 'Method not allowed'});
          }
        }
      } else {
        _send(response, 404, {'error': 'Route not found'});
      }
    } on FormatException catch (error) {
      _send(response, 400, {'error': error.message});
    } catch (_) {
      _send(response, 500, {'error': 'Unexpected server error'});
    } finally {
      await response.close();
    }
  }

  Future<Map<String, Object>> _readTask(
    HttpRequest request, {
    bool updating = false,
  }) async {
    const maxBytes = 4096;
    final bytes = <int>[];
    await for (final chunk in request) {
      if (bytes.length + chunk.length > maxBytes) {
        throw const FormatException('Request too large');
      }
      bytes.addAll(chunk);
    }
    final json = jsonDecode(utf8.decode(bytes));
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    final result = <String, Object>{};
    if (!updating || json.containsKey('title')) {
      final title = json['title'];
      if (title is! String ||
          title.trim().isEmpty ||
          title.trim().length > 100) {
        throw const FormatException(
          'Provide a title between 1 and 100 characters',
        );
      }
      result['title'] = title.trim();
    }
    if (json.containsKey('completed')) {
      final completed = json['completed'];
      if (completed is! bool) {
        throw const FormatException('completed must be true or false');
      }
      result['completed'] = completed;
    } else if (!updating) {
      result['completed'] = false;
    }
    if (result.isEmpty) {
      throw const FormatException('Provide a title or completion status');
    }
    return result;
  }

  void _send(HttpResponse response, int status, Object? body) {
    response.statusCode = status;
    response.write(jsonEncode(body));
  }
}

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8787);
  stdout.writeln('Course REST API listening on http://127.0.0.1:8787');
  final routes = TodoServer();
  server.listen(routes.handle);
}
