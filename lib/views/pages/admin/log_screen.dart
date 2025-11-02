import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;
  final String source;

  LogEntry(this.timestamp, this.level, this.message, this.source);
}

//Mockup Data
final List<LogEntry> MOCK_LOGS = [
  LogEntry(DateTime.now().subtract(const Duration(minutes: 5)), 'INFO', 'Dashboard loaded successfully.', 'UI/Render'),
  LogEntry(DateTime.now().subtract(const Duration(minutes: 3)), 'WARN', 'User session expiration approaching (15 min).', 'Auth/Service'),
  LogEntry(DateTime.now().subtract(const Duration(minutes: 1)), 'ERROR', 'Failed to fetch product list for category ID 404.', 'API/Products'),
  LogEntry(DateTime.now(), 'DEBUG', 'Widget rebuild triggered by state change.', 'FE/State'),
];

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final ScrollController _scrollController = ScrollController();
  List<LogEntry> currentLogs = MOCK_LOGS;
  String selectedLevel = 'ALL';

  // Lọc log theo cấp độ (FE Logic)
  void _filterLogs(String level) {
    setState(() {
      selectedLevel = level;
      if (level == 'ALL') {
        currentLogs = MOCK_LOGS;
      } else {
        currentLogs = MOCK_LOGS.where((log) => log.level == level).toList();
      }
    });
  }
  
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color darkBackground = Color(0xFFF0F4F8);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  Color _getColorForLevel(String level) {
    switch (level) {
      case 'ERROR': return Colors.red.shade600;
      case 'WARN': return Colors.amber.shade700;
      case 'INFO': return primaryBlue;
      case 'DEBUG': return Colors.grey.shade600;
      default: return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: darkBackground,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Log Viewer',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Real-time system activities and error tracking (FE Only)',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 20),

          _buildFilterChips(),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Bảng
                  _buildTableHeader(),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  // Danh sách Log
                  Expanded(
                    child: currentLogs.isEmpty
                        ? const Center(child: Text('No logs matching the filter.'))
                        : ListView.separated(
                            controller: _scrollController,
                            itemCount: currentLogs.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: Color(0xFFF5F5F5)),
                            itemBuilder: (context, index) {
                              return _buildLogRow(currentLogs[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final levels = ['ALL', 'ERROR', 'WARN', 'INFO', 'DEBUG'];
    return Wrap(
      spacing: 10,
      children: levels.map((level) {
        final isSelected = selectedLevel == level;
        return ActionChip(
          avatar: Icon(
            level == 'ERROR' ? FeatherIcons.alertTriangle : FeatherIcons.info,
            size: 16,
            color: isSelected ? Colors.white : _getColorForLevel(level),
          ),
          label: Text(
            level,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
          backgroundColor: isSelected ? primaryBlue : cardColor,
          side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
          onPressed: () => _filterLogs(level),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isSelected ? 5 : 0,
        );
      }).toList(),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: const [
          Expanded(flex: 2, child: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 1, child: Text('LEVEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 4, child: Text('MESSAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 2, child: Text('SOURCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
        ],
      ),
    );
  }

  Widget _buildLogRow(LogEntry log) {
    final levelColor = _getColorForLevel(log.level);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${log.timestamp.hour}:${log.timestamp.minute}:${log.timestamp.second}',
              style: const TextStyle(fontSize: 14, color: Colors.black54, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                log.level,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: levelColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              log.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.source,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}