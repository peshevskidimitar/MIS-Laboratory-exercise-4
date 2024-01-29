import 'dart:async';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/local_notifications_manager.dart';

class AddTimetableItem extends StatefulWidget {
  final FutureOr<void> Function(String subject, DateTime time) addTimetableItem;

  const AddTimetableItem({super.key, required this.addTimetableItem});

  @override
  State<AddTimetableItem> createState() => _AddTimetableItemState();
}

class _AddTimetableItemState extends State<AddTimetableItem> {
  final _subjectController = TextEditingController();
  DateTime dateTime = DateTime.now();

  void _submitData() async {
    if (_subjectController.text.isEmpty) return;
    widget.addTimetableItem(_subjectController.text, dateTime);
    Navigator.pop(context);
    await localNotificationsManager.scheduleNotification(
        LocalNotification(
          Random().nextInt(1000),
          '${_subjectController.text} - Exam',
          'Tomorrow you have an exam in ${_subjectController.text} at ${DateFormat("kk:mm").format(dateTime)}.',
          null,
        ),
        dateTime.subtract(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Exam"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: "Subject"),
            onSubmitted: (_) {},
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final date = await pickDate();
                    if (date == null) return;
                    final time = await pickTime();
                    if (time == null) return;

                    final dateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                      0,
                      0,
                      0,
                    );
                    setState(() => this.dateTime = dateTime);
                  },
                  child:
                      Text(DateFormat("yyyy-MM-dd – kk:mm").format(dateTime)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _submitData,
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> pickDate() => showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Future<TimeOfDay?> pickTime() => showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      );
}
