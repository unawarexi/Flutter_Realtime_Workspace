// project_template.dart
import 'package:flutter/material.dart';
import 'package:flutter_realtime_workspace/core/utils/helpers/helper_functions.dart';

class ProjectTemplateDropdown extends StatefulWidget {
  final List<Map<String, String>> projectTemplates;
  final ValueChanged<String?> onTemplateSelected;

  const ProjectTemplateDropdown({
    super.key,
    required this.projectTemplates,
    required this.onTemplateSelected,
  });

  @override
  _ProjectTemplateDropdownState createState() =>
      _ProjectTemplateDropdownState();
}

class _ProjectTemplateDropdownState extends State<ProjectTemplateDropdown> {
  String? _selectedTemplate;
  bool _isDropdownOpen = false;

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Template',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF1E293B).withOpacity(0.8)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTemplate ?? 'Choose a Template',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode
                        ? Colors.white70
                        : Colors.blueGrey,
                  ),
                ),
                Icon(
                  _isDropdownOpen
                      ? Icons.arrow_drop_up
                      : Icons.arrow_drop_down,
                  color: isDarkMode ? Colors.white54 : Colors.blueGrey,
                ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen) _buildTemplateDropdown(isDarkMode),
      ],
    );
  }

  Widget _buildTemplateDropdown(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E293B).withOpacity(0.95)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.18)
                : Colors.grey.withOpacity(0.13),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 240, // Set a max height for the dropdown
        child: SingleChildScrollView(
          child: Column(
            children: widget.projectTemplates.map((template) {
              final isSelected = _selectedTemplate == template['name'];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    _selectedTemplate = template['name'];
                    widget.onTemplateSelected(_selectedTemplate);
                    _isDropdownOpen = false;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDarkMode
                            ? const Color(0xFF1E40AF).withOpacity(0.12)
                            : const Color(0xFF3B82F6).withOpacity(0.08))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: isDarkMode
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF1E40AF),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDarkMode
                              ? const Color(0xFF334155)
                              : const Color(0xFFF1F5F9),
                        ),
                        child: Image.asset(
                          template['icon']!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template['name']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              template['description']!,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: isDarkMode
                                    ? Colors.white70
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Learn More',
                              style: TextStyle(
                                color: isDarkMode
                                    ? const Color(0xFF60A5FA)
                                    : Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.check_circle, color: Color(0xFF3B82F6), size: 22),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
