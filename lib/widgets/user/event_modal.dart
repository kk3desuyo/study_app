import 'package:flutter/material.dart';
import 'package:study_app/services/event.dart';

import 'package:study_app/models/event.dart';
import 'package:intl/intl.dart';
import 'package:study_app/theme/color.dart';

class EventModal extends StatefulWidget {
  final Event? existingEvent; // 既存のイベントがあれば渡す

  const EventModal({this.existingEvent, Key? key}) : super(key: key);

  @override
  _EventModalState createState() => _EventModalState();
}

class _EventModalState extends State<EventModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEvent != null) {
      _nameController.text = widget.existingEvent!.name;
      _selectedDate = widget.existingEvent!.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ), // 今日を含む過去の日付を選択不可にする
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('日付を選択してください。')),
        );
        return;
      }

      setState(() {
        _isSaving = true;
      });

      EventService eventService = EventService();
      Event event = Event(
        name: _nameController.text.trim(),
        date: _selectedDate!,
      );

      try {
        await eventService.addOrUpdateEvent(event);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.existingEvent != null
                  ? 'イベントが更新されました！'
                  : 'イベントが追加されました！')),
        );
        Navigator.of(context).pop(); // モーダルを閉じる
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存中にエラーが発生しました: $e')),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingEvent != null ? 'イベントを編集' : 'イベントを追加'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // イベント名入力
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'イベント名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'イベント名を入力してください。';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // イベント日付選択
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? '日付を選択してください'
                          : '選択日: ${DateFormat('yyyy/MM/dd').format(_selectedDate!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('日付選択'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveEvent,
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  '保存',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: subTheme,
          ),
        ),
      ],
    );
  }
}
