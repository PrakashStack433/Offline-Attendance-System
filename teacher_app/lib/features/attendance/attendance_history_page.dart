import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/date_utils.dart';
import '../../shared/widgets/empty_state.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String classId;

  const AttendanceHistoryPage({super.key, required this.classId});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(formatDateFull(_selectedDate)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AttendanceData>>(
              stream: db.attendanceDao.watchAttendanceByClassAndDate(
                widget.classId,
                _selectedDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data ?? [];

                if (records.isEmpty) {
                  return const EmptyState(
                    icon: Icons.event_busy,
                    title: 'No Records',
                    subtitle: 'No attendance marked on this date',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return FutureBuilder<Student?>(
                      future: db.studentDao.getStudentById(record.studentId),
                      builder: (context, studentSnap) {
                        final student = studentSnap.data;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: record.status == 'present'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Icon(
                                record.status == 'present'
                                    ? Icons.check
                                    : Icons.close,
                                color: record.status == 'present'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(student?.name ?? 'Unknown'),
                            subtitle: Text(
                              'Roll: ${student?.rollNumber ?? '-'} | ${record.status}',
                            ),
                            trailing: Text(
                              formatTime(record.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}
