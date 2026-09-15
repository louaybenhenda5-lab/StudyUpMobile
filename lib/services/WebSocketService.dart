import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/app_constants.dart';
import '../models/StudentStatus.dart';
import '../models/enums/Status.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  String? _sessionId;
  final _statusController = StreamController<StudentStatus>.broadcast();
  bool _connected = false;
  bool _subscriptionSent = false;
  StreamSubscription<dynamic>? _streamSub;

  Stream<StudentStatus> get statusStream => _statusController.stream;
  bool get isConnected => _connected;
  String? get currentSessionId => _sessionId;

  /// Connect to the backend STOMP WebSocket for real-time student status.
  ///
  /// Backend config (WebSocketSecurityConfig):
  ///   - endpoint /ws-native (raw WebSocket, no SockJS)
  ///   - simple broker on /admin, /topic, /queue
  ///   - app destination prefix /app
  ///   - session status is handled at /app/student.status
  ///   - teacher receives updates on /admin/{sessionId}
  /// JWT must be sent as "Authorization: Bearer <token>" native header
  /// in the CONNECT frame (JwtChannelInterceptor).
  void connect(String sessionId, {String? jwtToken}) {
    if (_connected && _sessionId == sessionId) return;

    dispose();

    _sessionId = sessionId;
    _subscriptionSent = false;

    try {
      final wsUrl = _buildWebSocketUrl();
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _connected = true;
      _sendStompConnect(jwtToken: jwtToken);
      _listen(jwtToken: jwtToken);
    } catch (e) {
      debugPrint('[WebSocketService] Connection error: $e');
      _connected = false;
    }
  }

  /// Send student status via STOMP SEND frame to /app/student.status.
  void sendStudentStatus(String studentId, Status status) {
    if (_channel == null || _sessionId == null || !_connected) {
      debugPrint('[WebSocketService] Not connected, cannot send status');
      return;
    }

    final payload = jsonEncode({
      'sessionId': _sessionId,
      'studentId': studentId,
      'status': status.name,
    });

    final bodyBytes = utf8.encode(payload);

    final frame = StringBuffer()
      ..writeln('SEND')
      ..writeln('destination:/app/student.status')
      ..writeln('content-type:application/json')
      ..writeln('content-length:${bodyBytes.length}')
      ..writeln()
      ..write(payload)
      ..write('\x00');

    _channel!.sink.add(frame.toString());
    debugPrint('[WebSocketService] Sent status for $studentId = ${status.name}');
  }

  void dispose() {
    _streamSub?.cancel();
    _streamSub = null;
    if (_channel != null) {
      try {
        _channel!.sink.close();
      } catch (_) {}
      _channel = null;
    }
    _connected = false;
    _sessionId = null;
    _subscriptionSent = false;
  }

  void _sendStompConnect({String? jwtToken}) {
    if (_channel == null) return;

    final buf = StringBuffer()
      ..writeln('CONNECT')
      ..writeln('accept-version:1.2,1.1,1.0')
      ..writeln('heart-beat:10000,10000');
    if (jwtToken != null && jwtToken.isNotEmpty) {
      buf.writeln('Authorization: Bearer $jwtToken');
    }
    buf.writeln();
    buf.write('\x00');

    _channel!.sink.add(buf.toString());
  }

  void _listen({String? jwtToken}) {
    _streamSub = _channel!.stream.listen(
      (message) {
        _handleMessage(message, jwtToken: jwtToken);
      },
      onError: (e) {
        debugPrint('[WebSocketService] Error: $e');
        _connected = false;
      },
      onDone: () {
        debugPrint('[WebSocketService] Connection closed');
        _connected = false;
      },
    );
  }

  void _handleMessage(Object message, {String? jwtToken}) {
    // Accept String or Uint8List frames (some servers deliver binary).
    String data;
    if (message is Uint8List) {
      data = utf8.decode(message, allowMalformed: true);
    } else if (message is List<int>) {
      data = utf8.decode(message, allowMalformed: true);
    } else {
      data = message.toString();
    }

    if (data.startsWith('CONNECTED')) {
      debugPrint('[WebSocketService] STOMP connected');
      _connected = true;
      _subscribe(jwtToken: jwtToken);
      return;
    }

    if (data.startsWith('ERROR')) {
      debugPrint('[WebSocketService] STOMP error frame: $data');
      return;
    }

    if (data.startsWith('MESSAGE')) {
      final body = _extractJsonBody(data);
      if (body == null) return;
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        final status = StudentStatus.fromJson(json);
        if (status.sessionId.isNotEmpty && status.studentId.isNotEmpty) {
          _statusController.add(status);
        }
      } catch (e) {
        debugPrint('[WebSocketService] Failed to parse message: $e');
      }
      return;
    }
  }

  void _subscribe({String? jwtToken}) {
    if (_sessionId == null || _channel == null || _subscriptionSent) return;
    _subscriptionSent = true;

    final sub = StringBuffer()
      ..writeln('SUBSCRIBE')
      ..writeln('id:sub-0')
      ..writeln('destination:/admin/$_sessionId')
      ..writeln()
      ..write('\x00');

    _channel!.sink.add(sub.toString());
    debugPrint('[WebSocketService] Subscribed to /admin/$_sessionId');
  }

  String? _extractJsonBody(String frame) {
    final nullIdx = frame.indexOf('\x00');
    final clean = nullIdx >= 0 ? frame.substring(0, nullIdx) : frame;

    // STOMP: headers terminated by a blank line, body follows.
    final headerEnd = clean.indexOf('\n\n');
    if (headerEnd < 0) return null;

    final body = clean.substring(headerEnd + 2).trim();
    if (body.isEmpty) return null;
    return body;
  }

  String _buildWebSocketUrl() {
    final baseUrl = NetworkConstants.url
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$baseUrl/ws-native';
  }

  void close() {
    dispose();
    _statusController.close();
  }
}