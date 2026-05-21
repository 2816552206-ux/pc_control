import 'dart:io';
import 'package:flutter/foundation.dart';

/// Wake-on-LAN 魔术包发送服务
class WolService {
  /// 发送魔术包到指定 MAC 地址
  /// [macAddress] 格式: "AA:BB:CC:DD:EE:FF" 或 "AA-BB-CC-DD-EE-FF"
  /// [broadcastIp] 广播地址，支持 IPv4 (255.255.255.255) 和 IPv6 (组播 FF02::1)
  /// [port] 目标端口，默认 9
  static Future<bool> sendMagicPacket({
    required String macAddress,
    String broadcastIp = '255.255.255.255',
    int port = 9,
  }) async {
    try {
      // 解析 MAC 地址为字节数组
      final macBytes = _parseMac(macAddress);
      if (macBytes.length != 6) {
        debugPrint('[WOL] MAC 地址格式错误: $macAddress');
        return false;
      }

      // 构建魔术包: 6字节 0xFF + MAC地址重复16次 = 102字节
      final packet = Uint8List(6 + 16 * 6);
      for (int i = 0; i < 6; i++) {
        packet[i] = 0xFF;
      }
      for (int i = 0; i < 16; i++) {
        packet.setAll(6 + i * 6, macBytes);
      }

      // 判断是 IPv6 地址
      final isIPv6 = broadcastIp.contains(':');

      debugPrint('[WOL] 发送魔术包到 $macAddress → $broadcastIp:$port (${isIPv6 ? "IPv6" : "IPv4"})');

      if (isIPv6) {
        // IPv6 使用组播或单播发送
        final socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv6,
          0,
        );
        socket.broadcastEnabled = false;

        final sent = socket.send(
          packet,
          InternetAddress(broadcastIp),
          port,
        );
        socket.close();

        debugPrint('[WOL] IPv6 发送结果: ${sent == packet.length ? "成功" : "失败"}');
        return sent == packet.length;
      } else {
        // IPv4 广播
        final socket = await RawDatagramSocket.bind(
          InternetAddress.anyIPv4,
          0,
        );
        socket.broadcastEnabled = true;

        final sent = socket.send(
          packet,
          InternetAddress(broadcastIp),
          port,
        );
        socket.close();

        debugPrint('[WOL] IPv4 发送结果: ${sent == packet.length ? "成功" : "失败"}');
        return sent == packet.length;
      }
    } catch (e) {
      debugPrint('[WOL] 发送异常: $e');
      return false;
    }
  }

  /// 将 MAC 地址字符串解析为字节数组
  static List<int> _parseMac(String mac) {
    return mac
        .replaceAll(RegExp(r'[:\-\.\s]'), '')
        .replaceAllMapped(RegExp(r'.{2}'), (m) => '${m.group(0)}:')
        .split(':')
        .where((s) => s.isNotEmpty)
        .map((s) => int.parse(s, radix: 16))
        .toList();
  }
}
