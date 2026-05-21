import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/pc_status.dart';

/// 电脑状态轮询服务
class StatusService {
  final String ip;
  final int port;
  Timer? _timer;
  bool _isPolling = false;

  StatusService({required this.ip, required this.port});

  bool get isPolling => _isPolling;

  /// 单次查询电脑状态
  Future<PcStatus> fetchStatus() async {
    try {
      final url = Uri.parse('http://$ip:$port/');
      debugPrint('[状态服务] 请求: $url');
      final response = await http.get(url, headers: {
        'Accept': 'text/plain; charset=utf-8',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final body = response.body;
        debugPrint('[状态服务] 响应: $body');
        return PcStatus.fromText(body);
      }
      debugPrint('[状态服务] HTTP ${response.statusCode}');
      return PcStatus.empty;
    } catch (e) {
      debugPrint('[状态服务] 请求失败: $e');
      return PcStatus.empty;
    }
  }

  /// 开始轮询，每次查询成功或失败后回调
  void startPolling({
    required Function(PcStatus status) onResult,
    Duration interval = const Duration(seconds: 3),
  }) {
    if (_isPolling) return;
    _isPolling = true;

    _timer = Timer.periodic(interval, (_) async {
      final status = await fetchStatus();
      onResult(status);

      // 如果电脑在线，降低轮询频率
      // 这里保持 3 秒不变，让用户在界面上自行控制
    });
  }

  /// 停止轮询
  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _isPolling = false;
  }

  void dispose() {
    stopPolling();
  }
}
