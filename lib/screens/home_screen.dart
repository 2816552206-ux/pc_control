import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pc_status.dart';
import '../services/wol_service.dart';
import '../services/status_service.dart';
import 'config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _ip = '192.168.1.100';
  String _mac = 'AA:BB:CC:DD:EE:FF';
  int _port = 8000;

  PcStatus _status = PcStatus.empty;
  StatusService? _statusService;
  bool _isPolling = false;
  bool _isSending = false;
  String _lastAction = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ip = prefs.getString('pc_ip') ?? '192.168.1.100';
      _mac = prefs.getString('pc_mac') ?? 'AA:BB:CC:DD:EE:FF';
      _port = prefs.getInt('pc_port') ?? 8000;
    });
  }

  void _startPolling() {
    if (_isPolling) return;

    _statusService = StatusService(ip: _ip, port: _port);
    _statusService!.startPolling(
      interval: const Duration(seconds: 3),
      onResult: (status) {
        if (mounted) {
          setState(() {
            _status = status;
            if (status.isOnline) {
              _lastAction = '电脑在线';
            }
          });
        }
      },
    );

    setState(() {
      _isPolling = true;
      _lastAction = '开始轮询...';
    });
  }

  void _stopPolling() {
    _statusService?.stopPolling();
    setState(() {
      _isPolling = false;
    });
  }

  Future<void> _sendMagicPacket() async {
    setState(() {
      _isSending = true;
      _lastAction = '正在发送魔术包...';
    });

    final ok = await WolService.sendMagicPacket(macAddress: _mac);

    if (mounted) {
      setState(() {
        _isSending = false;
        _lastAction = ok ? '魔术包已发送' : '发送失败';
      });
    }

    // 发送后自动开始轮询
    if (!_isPolling) {
      _startPolling();
    }
  }

  Future<void> _openConfig() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfigScreen(ip: _ip, mac: _mac, port: _port),
      ),
    );
    if (result == true) {
      await _loadConfig();
      // 配置更新后，重启轮询
      if (_isPolling) {
        _stopPolling();
        _startPolling();
      }
    }
  }

  @override
  void dispose() {
    _statusService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final online = _status.isOnline;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('远程开机控制'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openConfig,
            tooltip: '配置',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── 状态指示灯 ──
              _buildStatusIndicator(online),
              const SizedBox(height: 12),
              Text(
                online ? '电脑在线' : '电脑离线',
                style: TextStyle(
                  fontSize: 18,
                  color: online ? Colors.greenAccent : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_lastAction.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _lastAction,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
              const SizedBox(height: 28),

              // ── 开机按钮 ──
              _buildPowerButton(),
              const SizedBox(height: 12),
              Text(
                _mac,
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),

              const SizedBox(height: 28),

              // ── 轮询开关 ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sync, color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  const Text('状态轮询', style: TextStyle(color: Colors.white54)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isPolling,
                    onChanged: (v) => v ? _startPolling() : _stopPolling(),
                    activeThumbColor: Colors.greenAccent,
                    inactiveTrackColor: Colors.white12,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── 状态数据卡片 ──
              if (_isPolling || online) _buildStatusCards(),
              if (!_isPolling && !online)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Text(
                    '开启轮询或发送开机包后\n状态信息会显示在这里',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool online) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: online ? Colors.greenAccent : Colors.redAccent,
        boxShadow: [
          BoxShadow(
            color: (online ? Colors.greenAccent : Colors.redAccent)
                .withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPowerButton() {
    return GestureDetector(
      onTap: _isSending ? null : _sendMagicPacket,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: _isSending
                ? [Colors.orange, Colors.deepOrange]
                : [const Color(0xFF2EA043), const Color(0xFF1B5E20)],
          ),
          boxShadow: [
            BoxShadow(
              color: (_isSending ? Colors.orange : Colors.green)
                  .withValues(alpha: 0.4),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: _isSending
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              )
            : const Icon(Icons.power_settings_new, size: 56, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusCards() {
    final items = [
      ('数据时间', _status.dataTime, Icons.update),
      ('电脑开机时间', _status.bootTime, Icons.access_time),
      ('运行时长', _status.uptime, Icons.timer),
      ('CPU温度', _status.cpuTemp, Icons.thermostat),
      ('CPU使用率', _status.cpuPercent, Icons.memory),
      ('内存使用率', _status.memoryPercent, Icons.storage),
      ('磁盘使用率', _status.diskPercent, Icons.disc_full),
    ];

    // GPU 数据项
    final gpuItems = [
      if (_status.gpuName != '-' && _status.gpuName.isNotEmpty)
        ('显卡型号', _status.gpuName, Icons.videocam),
      ('显卡使用率', _status.gpuPercent, Icons.trending_up),
      if (_status.gpuTemp != '-' && _status.gpuTemp != 'N/A')
        ('显卡温度', _status.gpuTemp, Icons.thermostat),
      if (_status.gpuMemory != '-' && _status.gpuMemory != 'N/A')
        ('显卡显存', _status.gpuMemory, Icons.memory),
      if (_status.gpuPower != '-' && _status.gpuPower != 'N/A')
        ('显卡功耗', _status.gpuPower, Icons.bolt),
      if (_status.gpuFan != '-' && _status.gpuFan != 'N/A')
        ('显卡风扇', _status.gpuFan, Icons.air),
      if (_status.gpuClock != '-' && _status.gpuClock != 'N/A')
        ('显卡频率', _status.gpuClock, Icons.speed),
    ];

    return Column(
      children: [
        // 系统信息
        ...items.map((item) {
          return Card(
            color: const Color(0xFF161B22),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF30363D), width: 0.5),
            ),
            child: ListTile(
              leading: Icon(item.$3, color: Colors.white54, size: 22),
              title: Text(
                item.$1,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              trailing: Text(
                item.$2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
        // GPU 分隔
        if (gpuItems.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(Icons.videocam, color: Color(0xFF4CAF50), size: 16),
                SizedBox(width: 6),
                Text(
                  '显卡详情',
                  style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14),
                ),
              ],
            ),
          ),
          ...gpuItems.map((item) {
            return Card(
              color: const Color(0xFF1B2316),
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF2A3A20), width: 0.5),
              ),
              child: ListTile(
                leading: Icon(item.$3, color: Colors.white54, size: 22),
                title: Text(
                  item.$1,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                trailing: Text(
                  item.$2,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}
