import 'dart:async';
import 'package:flutter/material.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:intl/intl.dart';
import 'package:recomart/services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;
  final String source;

  LogEntry(this.timestamp, this.level, this.message, this.source);
}

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({super.key});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  final ScrollController _scrollController = ScrollController();
  List<LogEntry> _allLogs = [];
  List<LogEntry> _filteredLogs = [];
  String _selectedLevel = 'ALL';
  bool _isLoading = true;

  bool _isRetraining = false;
  String _trainingStatusMessage = "";
  StreamSubscription<DocumentSnapshot>? _trainingStatusSubscription;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
    _listenToTrainingStatus();
  }

  @override
  void dispose() {
    _trainingStatusSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _listenToTrainingStatus() {
    _trainingStatusSubscription = FirebaseFirestore.instance
        .collection('system_status') // Collection name
        .doc('training_model')       // Document ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final status = data?['status'] ?? 'IDLE';
        final message = data?['message'] ?? '';

        if (mounted) {
          setState(() {
            _trainingStatusMessage = message;

            if (status == 'RUNNING') {
              _isRetraining = true;
            } else if (status == 'SUCCESS' && _isRetraining) {
              _isRetraining = false;
              _showSnackBar('Retrain completed successfully!', Colors.green);
              _fetchLogs(); // Refresh logs to show new activity
            } else if (status == 'ERROR' && _isRetraining) {
              _isRetraining = false;
              _showSnackBar('Retrain failed: $message', Colors.red);
            } else {
              _isRetraining = false;
            }
          });
        }
      }
    });
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collectionGroup('interactions')
          .orderBy('timestamp', descending: true)
          .limit(300)
          .get();

      final logs = snapshot.docs.map((doc) {
        final data = doc.data();
        final type = data['interaction_type'] ?? 'unknown';

        String level = 'INFO';
        if (type == 'click' || type == 'addToCart') level = 'DEBUG';
        if (type == 'purchase' || type == 'purchase_mock') level = 'INFO';

        final userId = doc.reference.parent.parent?.id ?? 'Unknown';

        return LogEntry(
          (data['timestamp'] as Timestamp).toDate(),
          level,
          'User $userId $type item ${data['item_id']}',
          userId,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allLogs = logs;
          _filterLogs(_selectedLevel);
          _isLoading = false;
        });
      }
    } catch (e, st) {
      debugPrint('Firestore error: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRetrainDialog() {
    final TextEditingController passController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Retrain AI Model"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("This action consumes system resources. Please enter admin password to confirm."),
            const SizedBox(height: 15),
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Admin Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              if (passController.text.trim() != "admin123") {
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect Password!'), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.of(ctx).pop();
              _performRetrain(passController.text.trim());
            },
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performRetrain(String password) async {
    try {
      await ApiService.retrainModel(password);
      if (mounted) {
        _showSnackBar('Signal sent! Waiting for server...', Colors.blue);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to send retrain signal: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _filterLogs(String level) {
    setState(() {
      _selectedLevel = level;
      if (level == 'ALL') {
        _filteredLogs = List.from(_allLogs);
      } else {
        _filteredLogs = _allLogs.where((log) => log.level == level).toList();
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
    return Scaffold(
      backgroundColor: darkBackground,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                    _isRetraining 
                    ? Text(
                        'Status: $_trainingStatusMessage', 
                        style: const TextStyle(fontSize: 14, color: Colors.orange, fontWeight: FontWeight.bold),
                      )
                    : const Text(
                        'Real-time system activities and error tracking',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                  ],
                ),
                // Dynamic Button / Loader
                _isRetraining
                    ? const Row(
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text("Training...", style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: _showRetrainDialog,
                        icon: const Icon(FeatherIcons.refreshCw, size: 16),
                        label: const Text("Retrain AI"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Chips Row
            Row(
              children: [
                Expanded(child: _buildFilterChips()),
                IconButton(
                  onPressed: _fetchLogs,
                  icon: const Icon(Icons.refresh, color: Colors.grey),
                  tooltip: "Refresh Logs",
                )
              ],
            ),
            const SizedBox(height: 20),

            // Log Table Area
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
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator()) 
                  : Column(
                    children: [
                      // Table Header
                      _buildTableHeader(),
                      const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                      // Log List
                      Expanded(
                        child: _filteredLogs.isEmpty
                            ? const Center(child: Text('No logs found.'))
                            : ListView.separated(
                                controller: _scrollController,
                                itemCount: _filteredLogs.length,
                                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5, color: Color(0xFFF5F5F5)),
                                itemBuilder: (context, index) {
                                  return _buildLogRow(_filteredLogs[index]);
                                },
                              ),
                      ),
                    ],
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Methods ---
  
  Widget _buildFilterChips() {
    final levels = ['ALL', 'ERROR', 'WARN', 'INFO', 'DEBUG'];
    return Wrap(
      spacing: 10,
      children: levels.map((level) {
        final isSelected = _selectedLevel == level;
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
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('TIMESTAMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 1, child: Text('LEVEL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 4, child: Text('MESSAGE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
          Expanded(flex: 2, child: Text('USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54))),
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
              DateFormat('HH:mm:ss dd/MM').format(log.timestamp),
              style: const TextStyle(fontSize: 13, color: Colors.black54, fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align( 
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log.level,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: levelColor),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              log.message,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.source,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}