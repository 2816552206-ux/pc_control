import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  final String ip;
  final String mac;
  final int port;

  const ConfigScreen({
    super.key,
    required this.ip,
    required this.mac,
    required this.port,
  });

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late final TextEditingController _ipCtrl;
  late final TextEditingController _macCtrl;
  late final TextEditingController _portCtrl;

  @override
  void initState() {
    super.initState();
    _ipCtrl = TextEditingController(text: widget.ip);
    _macCtrl = TextEditingController(text: widget.mac);
    _portCtrl = TextEditingController(text: widget.port.toString());
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _macCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ip = _ipCtrl.text.trim();
    final mac = _macCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim());

    if (ip.isEmpty || mac.isEmpty || port == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pc_ip', ip);
    await prefs.setString('pc_mac', mac.toUpperCase());
    await prefs.setInt('pc_port', port);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置已保存'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('电脑配置'),
        backgroundColor: const Color(0xFF161B22),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLabel('电脑 IP 地址 (IPv4 或 IPv6)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _ipCtrl,
              hint: '例如 192.168.1.100 或 240e::d36',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20),
            _buildLabel('MAC 地址（物理地址）'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _macCtrl,
              hint: '例如 AA:BB:CC:DD:EE:FF',
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9A-Fa-f:\-]'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildLabel('状态端口'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _portCtrl,
              hint: '默认 8000',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d]')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '提示：电脑开机后会自动启动唤醒开机项.py（端口8000），'
              'App 轮询此端口即可检测开机状态。',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('保存', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization? textCapitalization,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: const Color(0xFF161B22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.greenAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
