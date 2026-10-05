import 'dart:async';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import '../models/event.dart';
import 'database_service.dart';

class McpServer {
  final DatabaseService _db;
  HttpServer? _server;
  final _clients = <WebSocket>[];

  McpServer(this._db);

  Future<void> start({int port = 8080}) async {
    final router = Router();

    // MCP 协议端点
    router.post('/mcp', _handleMcpRequest);
    router.get('/mcp/sse', _handleSseConnection);

    // 健康检查
    router.get('/health', (Request request) {
      return Response.ok(jsonEncode({'status': 'ok'}));
    });

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(router.call);

    _server = await io.serve(handler, '0.0.0.0', port);
    print('MCP Server running on port $port');
  }

  Future<void> stop() async {
    await _server?.close();
    for (final client in _clients) {
      await client.close();
    }
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }
        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  static const _corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  Future<Response> _handleMcpRequest(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final method = data['method'] as String?;
      final params = data['params'] as Map<String, dynamic>?;
      final id = data['id'];

      if (method == null) {
        return Response.badRequest(body: jsonEncode({'error': 'Method is required'}));
      }

      final result = await _handleMethod(method, params ?? {});

      return Response.ok(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': id,
          'result': result,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Future<Map<String, dynamic>> _handleMethod(
      String method, Map<String, dynamic> params) async {
    switch (method) {
      case 'tools/list':
        return _listTools();
      case 'tools/call':
        return _callTool(params);
      default:
        return {'error': 'Unknown method: $method'};
    }
  }

  Map<String, dynamic> _listTools() {
    return {
      'tools': [
        {
          'name': 'create_event',
          'description': 'Create a new calendar event',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'title': {'type': 'string', 'description': 'Event title'},
              'description': {'type': 'string', 'description': 'Event description'},
              'startTime': {'type': 'string', 'description': 'Start time (ISO8601)'},
              'endTime': {'type': 'string', 'description': 'End time (ISO8601)'},
              'location': {'type': 'string', 'description': 'Event location'},
              'priority': {
                'type': 'string',
                'enum': ['low', 'medium', 'high', 'urgent'],
                'description': 'Event priority'
              },
            },
            'required': ['title', 'startTime', 'endTime'],
          },
        },
        {
          'name': 'update_event',
          'description': 'Update an existing calendar event',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string', 'description': 'Event ID'},
              'title': {'type': 'string', 'description': 'Event title'},
              'description': {'type': 'string', 'description': 'Event description'},
              'startTime': {'type': 'string', 'description': 'Start time (ISO8601)'},
              'endTime': {'type': 'string', 'description': 'End time (ISO8601)'},
              'location': {'type': 'string', 'description': 'Event location'},
              'priority': {
                'type': 'string',
                'enum': ['low', 'medium', 'high', 'urgent'],
                'description': 'Event priority'
              },
              'status': {
                'type': 'string',
                'enum': ['pending', 'inProgress', 'completed', 'cancelled'],
                'description': 'Event status'
              },
            },
            'required': ['id'],
          },
        },
        {
          'name': 'delete_event',
          'description': 'Delete a calendar event',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string', 'description': 'Event ID to delete'},
            },
            'required': ['id'],
          },
        },
        {
          'name': 'query_events',
          'description': 'Query calendar events in a date range',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'startTime': {'type': 'string', 'description': 'Start time (ISO8601)'},
              'endTime': {'type': 'string', 'description': 'End time (ISO8601)'},
            },
            'required': ['startTime', 'endTime'],
          },
        },
        {
          'name': 'get_event',
          'description': 'Get a single event by ID',
          'inputSchema': {
            'type': 'object',
            'properties': {
              'id': {'type': 'string', 'description': 'Event ID'},
            },
            'required': ['id'],
          },
        },
      ],
    };
  }

  Future<Map<String, dynamic>> _callTool(Map<String, dynamic> params) async {
    final name = params['name'] as String?;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    if (name == null) {
      return {'error': 'Tool name is required'};
    }

    switch (name) {
      case 'create_event':
        return _createEvent(arguments);
      case 'update_event':
        return _updateEvent(arguments);
      case 'delete_event':
        return _deleteEvent(arguments);
      case 'query_events':
        return _queryEvents(arguments);
      case 'get_event':
        return _getEvent(arguments);
      default:
        return {'error': 'Unknown tool: $name'};
    }
  }

  Future<Map<String, dynamic>> _createEvent(Map<String, dynamic> args) async {
    try {
      final event = ScheduleEvent(
        title: args['title'] ?? 'Untitled',
        description: args['description'],
        startTime: DateTime.parse(args['startTime']),
        endTime: DateTime.parse(args['endTime']),
        location: args['location'],
        priority: _parsePriority(args['priority']),
      );
      await _db.insertEvent(event);
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Event created successfully',
          }
        ],
        'data': event.toMap(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _updateEvent(Map<String, dynamic> args) async {
    try {
      final id = args['id'] as String?;
      if (id == null) return {'error': 'Event ID is required'};

      // Get existing event
      final events = await _db.getEvents(
        DateTime.fromMillisecondsSinceEpoch(0),
        DateTime.now().add(const Duration(days: 365 * 10)),
      );
      final existing = events.where((e) => e.id == id).firstOrNull;
      if (existing == null) return {'error': 'Event not found'};

      final updated = existing.copyWith(
        title: args['title'],
        description: args['description'],
        startTime: args['startTime'] != null
            ? DateTime.parse(args['startTime'])
            : null,
        endTime: args['endTime'] != null
            ? DateTime.parse(args['endTime'])
            : null,
        location: args['location'],
        priority: args['priority'] != null
            ? _parsePriority(args['priority'])
            : null,
        status: args['status'] != null
            ? _parseStatus(args['status'])
            : null,
      );
      await _db.updateEvent(updated);
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Event updated successfully',
          }
        ],
        'data': updated.toMap(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _deleteEvent(Map<String, dynamic> args) async {
    try {
      final id = args['id'] as String?;
      if (id == null) return {'error': 'Event ID is required'};
      await _db.deleteEvent(id);
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Event deleted successfully',
          }
        ],
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _queryEvents(Map<String, dynamic> args) async {
    try {
      final start = DateTime.parse(args['startTime']);
      final end = DateTime.parse(args['endTime']);
      final events = await _db.getEvents(start, end);
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Found ${events.length} events',
          }
        ],
        'data': events.map((e) => e.toMap()).toList(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> _getEvent(Map<String, dynamic> args) async {
    try {
      final id = args['id'] as String?;
      if (id == null) return {'error': 'Event ID is required'};
      final events = await _db.getEvents(
        DateTime.fromMillisecondsSinceEpoch(0),
        DateTime.now().add(const Duration(days: 365 * 10)),
      );
      final event = events.where((e) => e.id == id).firstOrNull;
      if (event == null) return {'error': 'Event not found'};
      return {
        'content': [
          {
            'type': 'text',
            'text': 'Event found',
          }
        ],
        'data': event.toMap(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  EventPriority _parsePriority(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return EventPriority.urgent;
      case 'high':
        return EventPriority.high;
      case 'low':
        return EventPriority.low;
      default:
        return EventPriority.medium;
    }
  }

  EventStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
        return EventStatus.inProgress;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.pending;
    }
  }

  Future<Response> _handleSseConnection(Request request) async {
    // SSE 连接处理（用于实时通知）
    return Response.ok(
      Stream.fromIterable(['data: {"type": "connected"}\n\n']),
      headers: {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      },
    );
  }
}
