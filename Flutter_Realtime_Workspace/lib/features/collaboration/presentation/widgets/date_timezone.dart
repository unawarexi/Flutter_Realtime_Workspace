import 'package:flutter/material.dart';
import 'package:flutter_realtime_workspace/core/utils/formatters.dart';
import 'package:flutter_realtime_workspace/shared/styles/colors.dart';

class DateTimeTimezonePicker extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String selectedTimezone;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<String> onTimezoneChanged;
  final bool isDarkMode;

  const DateTimeTimezonePicker({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedTimezone,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onTimezoneChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final timezones = TFormatter.getAllTimeZoneNames();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateTimeTile(
                title: 'Date',
                value: TFormatter.formatDateForUi(selectedDate),
                icon: Icons.calendar_today_outlined,
                isDarkMode: isDarkMode,
                onTap: () async {
                  final picked = await TFormatter.pickDate(context, selectedDate);
                  if (picked != null && picked != selectedDate) {
                    onDateChanged(picked);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeTile(
                title: 'Time',
                value: TFormatter.formatTimeForUi(selectedTime),
                icon: Icons.access_time_rounded,
                isDarkMode: isDarkMode,
                onTap: () async {
                  final picked = await TFormatter.pickTime(context, selectedTime);
                  if (picked != null && picked != selectedTime) {
                    onTimeChanged(picked);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedTimezone,
          onChanged: (value) {
            if (value != null) onTimezoneChanged(value);
          },
          items: timezones.map((tz) {
            return DropdownMenuItem<String>(
              value: tz,
              child: Text(
                TFormatter.formatTimezone(tz),
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white : TColors.backgroundDark,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            labelText: 'Timezone',
            prefixIcon: Icon(
              Icons.public,
              color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
              size: 14,
            ),
            labelStyle: TextStyle(
              color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode ? TColors.borderDark : TColors.borderLight,
                width: 0.8,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode ? TColors.borderDark : TColors.borderLight,
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          ),
          dropdownColor: isDarkMode ? TColors.cardColorDark : Colors.white,
        ),
      ],
    );
  }

  Widget _buildDateTimeTile({
    required String title,
    required String value,
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : TColors.backgroundDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
