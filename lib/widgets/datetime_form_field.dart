import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatetimeFormField extends StatefulWidget {
  final TextEditingController controller;
  final DateTime firstDate;
  final DateTime? lastDate;
  final TimeOfDay? initialTime;
  final void Function(DateTime? newDate)? onSaved;
  final String? Function(DateTime?)? validator;
  final InputDecoration? decoration;
  final String dateFormat;
  final bool allowClearButton;

  const DatetimeFormField({
    super.key,
    required this.controller,
    required this.firstDate,
    this.lastDate,
    this.initialTime,
    this.onSaved,
    this.validator,
    this.decoration,
    this.dateFormat = 'dd/MM/yyyy hh:mm a',
    this.allowClearButton = true,
  });

  @override
  State<DatetimeFormField> createState() => _DatetimeFormFieldState();
}

class _DatetimeFormFieldState extends State<DatetimeFormField> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    var decoration = widget.decoration ?? const InputDecoration();

    if (selectedDate != null && widget.allowClearButton) {
      decoration = decoration.copyWith(
        suffixIcon: IconButton(
          onPressed: () {
            widget.controller.clear();
            FocusScope.of(context).unfocus();

            setState(() {
              selectedDate = null;
            });
          },
          icon: const Icon(Icons.close),
        ),
      );
    }

    return TextFormField(
      onSaved: (newValue) => widget.onSaved?.call(selectedDate),
      controller: widget.controller,
      readOnly: true,
      decoration: decoration,
      onTap: () async {
        var dateResult = await showDatePicker(
          context: context,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate ??
              widget.firstDate.add(const Duration(days: 365 * 100)),
          initialDate: selectedDate,
        );

        if (dateResult == null || !mounted) {
          return;
        }

        var initialTime = selectedDate != null
            ? TimeOfDay.fromDateTime(selectedDate!)
            : widget.initialTime;

        var timeResult = await showTimePicker(
          // ignore: use_build_context_synchronously
          context: context,
          initialTime: initialTime ??
              TimeOfDay.fromDateTime(
                  DateTime.now().add(const Duration(hours: 2))),
        );

        if (timeResult == null) {
          return;
        }

        final date = DateTime(
          dateResult.year,
          dateResult.month,
          dateResult.day,
          timeResult.hour,
          timeResult.minute,
        );

        widget.controller.text = DateFormat(widget.dateFormat).format(date);

        setState(() {
          selectedDate = date;
        });
      },
      validator: (value) => widget.validator?.call(selectedDate),
    );
  }
}
