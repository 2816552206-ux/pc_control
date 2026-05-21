/// 电脑状态数据模型
class PcStatus {
  final String bootTime;
  final String uptime;
  final String cpuTemp;
  final String cpuPercent;
  final String memoryPercent;
  final String gpuPercent;
  final String diskPercent;
  final bool isOnline;

  const PcStatus({
    required this.bootTime,
    required this.uptime,
    required this.cpuTemp,
    required this.cpuPercent,
    required this.memoryPercent,
    required this.gpuPercent,
    required this.diskPercent,
    this.isOnline = false,
  });

  static const empty = PcStatus(
    bootTime: '-',
    uptime: '-',
    cpuTemp: '-',
    cpuPercent: '-',
    memoryPercent: '-',
    gpuPercent: '-',
    diskPercent: '-',
    isOnline: false,
  );

  factory PcStatus.fromText(String text) {
    String extract(String key) {
      final regex = RegExp('$key[：:]\\s*(.+)');
      final match = regex.firstMatch(text);
      return match?.group(1)?.trim() ?? '-';
    }

    return PcStatus(
      bootTime: extract('电脑开机时间'),
      uptime: extract('运行时长'),
      cpuTemp: extract('CPU温度'),
      cpuPercent: extract('CPU使用率'),
      memoryPercent: extract('内存使用率'),
      gpuPercent: extract('显卡使用率'),
      diskPercent: extract('磁盘使用率\\(C盘\\)'),
      isOnline: true,
    );
  }
}
