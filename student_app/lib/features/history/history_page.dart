import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database/student_database.dart';
import '../../core/services/server_service.dart';
import '../../shared/widgets/empty_state.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final db = context.read<StudentDatabase>();
      final profile = await db.getProfile();

      if (profile == null) {
        setState(() {
          _error = 'No profile found. Set up your profile first.';
          _isLoading = false;
        });
        return;
      }

      if (profile.teacherServerUrl == null) {
        setState(() {
          _error = 'No server connected. Join a class first.';
          _isLoading = false;
        });
        return;
      }

      final serverService = ServerService();
      serverService.setServerUrl(profile.teacherServerUrl!);

      final records = await serverService.getAttendanceHistory(profile.id);

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading history: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 48, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: _loadHistory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _records.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_busy,
                      title: 'No Records',
                      subtitle: 'No attendance records found',
                    )
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final record = _records[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: const Icon(Icons.check,
                                    color: Colors.green),
                              ),
                              title: Text(record['class_name'] ?? record['className'] ?? 'Unknown'),
                              subtitle: Text(record['date'] ?? ''),
                              trailing: Text(record['time'] ?? ''),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
