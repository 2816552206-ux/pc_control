/// 电脑状态数据模型
class PcStatus {
  final String dataTime;
  final String bootTime;
  final String uptime;
  final String cpuTemp;
  final String cpuPercent;
  final String memoryPercent;
  final String diskPercent;
  // GPU 详细数据
  final String gpuName;
  final String gpuPercent;
  final String gpuTemp;
  final String gpuMemory;
  final String gpuPower;
  final String gpuFan;
  final String gpuClock;
  final bool isOnline;

  const PcStatus({
    required this.dataTime,
    required this.bootTime,
    required this.uptime,
    required this.cpuTemp,
    required this.cpuPercent,
    required this.memoryPercent,
    required this.diskPercent,
    required this.gpuName,
    required this.gpuPercent,
    required this.gpuTemp,
    required this.gpuMemory,
    required this.gpuPower,
    required this.gpuFan,
    required this.gpuClock,
    this.isOnline = false,
  });

  static const empty = PcStatus(
    dataTime: '-',
    bootTime: '-',
    uptime: '-',
    cpuTemp: '-',
    cpuPercent: '-',
    memoryPercent: '-',
    diskPercent: '-',
    gpuName: '-',
    gpuPercent: '-',
    gpuTemp: '-',
    gpuMemory: '-',
    gpuPower: '-',
    gpuFan: '-',
    gpuClock: '-',
    isOnline: false,
  );

  factory PcStatus.fromText(String text) {
    String extract(String key) {
      final regex = RegExp('$key[：:]\\s*(.+)');
      final match = regex.firstMatch(text);
      return match?.group(1)?.trim() ?? '-';
    }

    return PcStatus(
      dataTime: extract('数据时间'),
      bootTime: extract('电脑开机时间'),
      uptime: extract('运行时长'),
      cpuTemp: extract('CPU温度'),
      cpuPercent: extract('CPU使用率'),
      memoryPercent: extract('内存使用率'),
      diskPercent: extract('磁盘使用率'),
      gpuName: extract('显卡型号'),
      gpuPercent: extract('显卡使用率'),
      gpuTemp: extract('显卡温度'),
      gpuMemory: extract('显卡显存'),
      gpuPower: extract('显卡功耗'),
      gpuFan: extract('显卡风扇'),
      gpuClock: extract('显卡频率'),
      isOnline: true,
    );
  }
}
