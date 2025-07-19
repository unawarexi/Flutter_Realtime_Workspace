import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_realtime_workspace/shared/styles/colors.dart';
import 'package:flutter_realtime_workspace/core/utils/helpers/helper_functions.dart';

class ScheduleMeet extends StatefulWidget {
  const ScheduleMeet({super.key});

  @override
  State<ScheduleMeet> createState() => _ScheduleMeetState();
}

class _ScheduleMeetState extends State<ScheduleMeet>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _duration = '60 minutes';
  String _repeatOption = 'None';
  String _meetingType = 'Virtual';
  String _reminderTime = '15 minutes before';
  List<String> _selectedParticipants = [];
  List<String> _attachments = [];

  final List<String> _durationOptions = [
    '15 minutes', '30 minutes', '45 minutes', '60 minutes', 
    '90 minutes', '2 hours', '3 hours', '4 hours'
  ];
  
  final List<String> _repeatOptions = [
    'None', 'Daily', 'Weekly', 'Bi-weekly', 'Monthly'
  ];
  
  final List<String> _reminderOptions = [
    '5 minutes before', '15 minutes before', '30 minutes before', 
    '1 hour before', '2 hours before', '1 day before'
  ];
  
  final List<String> _availableParticipants = [
    'John Doe', 'Jane Smith', 'Mike Johnson', 'Sarah Williams',
    'David Brown', 'Lisa Davis', 'Tom Wilson', 'Emily Taylor'
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? TColors.backgroundDarkAlt : TColors.backgroundLight,
      appBar: _buildAppBar(isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(isDarkMode),
                        const SizedBox(height: 24),
                        _buildMeetingDetailsSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildDateTimeSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildDurationRepeatSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildParticipantsSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildMeetingTypeSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildLocationSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildDescriptionSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildNotificationSection(isDarkMode),
                        const SizedBox(height: 20),
                        _buildAttachmentsSection(isDarkMode),
                        const SizedBox(height: 30),
                        _buildScheduleButton(isDarkMode),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? TColors.backgroundDarkAlt : TColors.backgroundLight,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.cardColorDark : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDarkMode ? Colors.white : TColors.backgroundDark,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Schedule Meeting',
        style: TextStyle(
          color: isDarkMode ? Colors.white : TColors.backgroundDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode ? TColors.cardColorDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? TColors.borderDark : TColors.borderLight,
              width: 0.8,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.calendar_month_outlined,
              color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
              size: 18,
            ),
            onPressed: () {
              // Show calendar conflicts
              _showConflictChecker(isDarkMode);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [TColors.buttonPrimary.withOpacity(0.1), TColors.lightBlue.withOpacity(0.05)]
              : [TColors.buttonPrimaryLight.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Meeting',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? Colors.white : TColors.backgroundDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Schedule meetings with your team effortlessly',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingDetailsSection(bool isDarkMode) {
    return _buildSection(
      title: 'Meeting Details',
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          _buildTextField(
            controller: _titleController,
            label: 'Meeting Title',
            hint: 'Enter meeting title',
            icon: Icons.title_rounded,
            isDarkMode: isDarkMode,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a meeting title';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(bool isDarkMode) {
    return _buildSection(
      title: 'Date & Time',
      isDarkMode: isDarkMode,
      child: Row(
        children: [
          Expanded(
            child: _buildDateTimeTile(
              title: 'Date',
              value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              icon: Icons.calendar_today_outlined,
              isDarkMode: isDarkMode,
              onTap: () => _selectDate(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDateTimeTile(
              title: 'Time',
              value: _selectedTime.format(context),
              icon: Icons.access_time_rounded,
              isDarkMode: isDarkMode,
              onTap: () => _selectTime(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationRepeatSection(bool isDarkMode) {
    return _buildSection(
      title: 'Duration & Repeat',
      isDarkMode: isDarkMode,
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownField(
              label: 'Duration',
              value: _duration,
              items: _durationOptions,
              icon: Icons.timer_outlined,
              isDarkMode: isDarkMode,
              onChanged: (value) => setState(() => _duration = value!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdownField(
              label: 'Repeat',
              value: _repeatOption,
              items: _repeatOptions,
              icon: Icons.repeat_rounded,
              isDarkMode: isDarkMode,
              onChanged: (value) => setState(() => _repeatOption = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(bool isDarkMode) {
    return _buildSection(
      title: 'Participants',
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          _buildParticipantSelector(isDarkMode),
          if (_selectedParticipants.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSelectedParticipants(isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildMeetingTypeSection(bool isDarkMode) {
    return _buildSection(
      title: 'Meeting Type',
      isDarkMode: isDarkMode,
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              title: 'Virtual',
              isSelected: _meetingType == 'Virtual',
              icon: Icons.videocam_outlined,
              isDarkMode: isDarkMode,
              onTap: () => setState(() => _meetingType = 'Virtual'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTypeOption(
              title: 'Physical',
              isSelected: _meetingType == 'Physical',
              icon: Icons.location_on_outlined,
              isDarkMode: isDarkMode,
              onTap: () => setState(() => _meetingType = 'Physical'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(bool isDarkMode) {
    return _buildSection(
      title: _meetingType == 'Virtual' ? 'Meeting Link' : 'Location',
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          if (_meetingType == 'Virtual')
            _buildTextField(
              controller: _linkController,
              label: 'Meeting Link',
              hint: 'Enter meeting link or generate one',
              icon: Icons.link_rounded,
              isDarkMode: isDarkMode,
            )
          else
            _buildTextField(
              controller: _locationController,
              label: 'Address',
              hint: 'Enter location address',
              icon: Icons.location_on_outlined,
              isDarkMode: isDarkMode,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.map_outlined,
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                  size: 20,
                ),
                onPressed: () {
                  // Open Google Maps to select location
                  _openLocationPicker();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDarkMode) {
    return _buildSection(
      title: 'Description/Agenda',
      isDarkMode: isDarkMode,
      child: _buildTextField(
        controller: _descriptionController,
        label: 'Description',
        hint: 'Enter meeting description or agenda',
        icon: Icons.description_outlined,
        isDarkMode: isDarkMode,
        maxLines: 4,
      ),
    );
  }

  Widget _buildNotificationSection(bool isDarkMode) {
    return _buildSection(
      title: 'Notifications',
      isDarkMode: isDarkMode,
      child: _buildDropdownField(
        label: 'Reminder',
        value: _reminderTime,
        items: _reminderOptions,
        icon: Icons.notifications_outlined,
        isDarkMode: isDarkMode,
        onChanged: (value) => setState(() => _reminderTime = value!),
      ),
    );
  }

  Widget _buildAttachmentsSection(bool isDarkMode) {
    return _buildSection(
      title: 'Attachments',
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          _buildAttachmentButton(isDarkMode),
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAttachmentsList(isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight).withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _scheduleMeeting(),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_send_rounded,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Schedule Meeting',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? TColors.cardColorDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? TColors.borderDark : TColors.borderLight,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.03),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : TColors.backgroundDark,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    int maxLines = 1,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(
        color: isDarkMode ? Colors.white : TColors.backgroundDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
          size: 20,
        ),
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(
          color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: isDarkMode ? TColors.textTertiaryLight : TColors.textSecondaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
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
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : TColors.backgroundDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required bool isDarkMode,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
          size: 20,
        ),
        labelStyle: TextStyle(
          color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.white : TColors.backgroundDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: isDarkMode ? TColors.cardColorDark : Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: isDarkMode ? Colors.white : TColors.backgroundDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantSelector(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _showParticipantSelector(isDarkMode),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedParticipants.isEmpty
                    ? 'Select participants'
                    : '${_selectedParticipants.length} participant${_selectedParticipants.length > 1 ? 's' : ''} selected',
                style: TextStyle(
                  color: _selectedParticipants.isEmpty
                      ? (isDarkMode ? TColors.textTertiaryLight : TColors.textSecondaryDark)
                      : (isDarkMode ? Colors.white : TColors.backgroundDark),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedParticipants(bool isDarkMode) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _selectedParticipants.map((participant) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight).withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                participant,
                style: TextStyle(
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedParticipants.remove(participant);
                  });
                },
                child: Icon(
                  Icons.close_rounded,
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                  size: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeOption({
    required String title,
    required bool isSelected,
    required IconData icon,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight).withOpacity(0.1)
              : (isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? TColors.buttonPrimary : TColors.buttonPrimaryLight)
                : (isDarkMode ? TColors.borderDark : TColors.borderLight),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDarkMode ? TColors.lightBlue : TColors.buttonPrimary)
                  : (isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? (isDarkMode ? Colors.white : TColors.backgroundDark)
                    : (isDarkMode ? TColors.textSecondaryDark : TColors.textTertiaryLight),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(bool isDarkMode) {
    return GestureDetector(
      onTap: () => _addAttachment(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? TColors.backgroundDarkAlt : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDarkMode ? TColors.borderDark : TColors.borderLight,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_file_rounded,
              color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Attachment',
              style: TextStyle(
                color: isDarkMode ? Colors.white : TColors.backgroundDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsList(bool isDarkMode) {
    return Column(
      children: _attachments.map((attachment) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: (isDarkMode
                    ? TColors.buttonPrimary
                    : TColors.buttonPrimaryLight)
                .withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isDarkMode
                      ? TColors.buttonPrimary
                      : TColors.buttonPrimaryLight)
                  .withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  attachment,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : TColors.backgroundDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _attachments.remove(attachment);
                  });
                },
                child: Icon(
                  Icons.close_rounded,
                  color: isDarkMode
                      ? TColors.textSecondaryDark
                      : TColors.textTertiaryLight,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Date and Time Pickers
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TColors.buttonPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TColors.buttonPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Participant Selection Dialog
  void _showParticipantSelector(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: isDarkMode ? TColors.cardColorDark : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode ? TColors.borderDark : TColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Participants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDarkMode
                                ? Colors.white
                                : TColors.backgroundDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Done',
                            style: TextStyle(
                              color: isDarkMode
                                  ? TColors.lightBlue
                                  : TColors.buttonPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Participants list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _availableParticipants.length,
                      itemBuilder: (context, index) {
                        final participant = _availableParticipants[index];
                        final isSelected =
                            _selectedParticipants.contains(participant);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? TColors.backgroundDarkAlt
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDarkMode
                                  ? TColors.borderDark
                                  : TColors.borderLight,
                              width: 0.8,
                            ),
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  _selectedParticipants.add(participant);
                                } else {
                                  _selectedParticipants.remove(participant);
                                }
                              });
                              setState(() {}); // Update parent state
                            },
                            title: Text(
                              participant,
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : TColors.backgroundDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${participant.toLowerCase().replaceAll(' ', '.')}@company.com',
                              style: TextStyle(
                                color: isDarkMode
                                    ? TColors.textSecondaryDark
                                    : TColors.textTertiaryLight,
                                fontSize: 12,
                              ),
                            ),
                            activeColor: isDarkMode
                                ? TColors.lightBlue
                                : TColors.buttonPrimary,
                            checkColor: Colors.white,
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Conflict Checker Dialog
  void _showConflictChecker(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? TColors.cardColorDark : Colors.white,
          title: Text(
            'Schedule Conflicts',
            style: TextStyle(
              color: isDarkMode ? Colors.white : TColors.backgroundDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Checking for conflicts on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTime.format(context)}...',
                style: TextStyle(
                  color: isDarkMode
                      ? TColors.textSecondaryDark
                      : TColors.textTertiaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'No conflicts found',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Location Picker (Google Maps integration placeholder)
  void _openLocationPicker() {
    // This would typically open Google Maps or a location picker
    // For now, showing a simple dialog
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = THelperFunctions.isDarkMode(context);
        return AlertDialog(
          backgroundColor: isDarkMode ? TColors.cardColorDark : Colors.white,
          title: Text(
            'Select Location',
            style: TextStyle(
              color: isDarkMode ? Colors.white : TColors.backgroundDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Google Maps integration would be implemented here to allow users to select a location.',
            style: TextStyle(
              color: isDarkMode
                  ? TColors.textSecondaryDark
                  : TColors.textTertiaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode
                      ? TColors.textSecondaryDark
                      : TColors.textTertiaryLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _locationController.text = 'Selected Location from Maps';
                Navigator.pop(context);
              },
              child: Text(
                'Use Current Location',
                style: TextStyle(
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add Attachment
  void _addAttachment() {
    // This would typically open file picker
    // For demo purposes, adding dummy attachments
    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = THelperFunctions.isDarkMode(context);
        return AlertDialog(
          backgroundColor: isDarkMode ? TColors.cardColorDark : Colors.white,
          title: Text(
            'Add Attachment',
            style: TextStyle(
              color: isDarkMode ? Colors.white : TColors.backgroundDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.insert_drive_file_outlined,
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                ),
                title: Text(
                  'Choose from Files',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : TColors.backgroundDark,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _attachments.add('Meeting_Agenda.pdf');
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : TColors.backgroundDark,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _attachments.add(
                        'photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDarkMode
                      ? TColors.textSecondaryDark
                      : TColors.textTertiaryLight,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Schedule Meeting Function
  void _scheduleMeeting() {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final isDarkMode = THelperFunctions.isDarkMode(context);
          return AlertDialog(
            backgroundColor: isDarkMode ? TColors.cardColorDark : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? TColors.lightBlue : TColors.buttonPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Scheduling meeting...',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : TColors.backgroundDark,
                  ),
                ),
              ],
            ),
          );
        },
      );

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // Close loading dialog

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) {
            final isDarkMode = THelperFunctions.isDarkMode(context);
            return AlertDialog(
              backgroundColor:
                  isDarkMode ? TColors.cardColorDark : Colors.white,
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Success!',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : TColors.backgroundDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Meeting "${_titleController.text}" has been scheduled successfully.',
                style: TextStyle(
                  color: isDarkMode
                      ? TColors.textSecondaryDark
                      : TColors.textTertiaryLight,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    Navigator.pop(context); // Return to previous screen
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: isDarkMode
                          ? TColors.lightBlue
                          : TColors.buttonPrimary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add to calendar functionality would go here
                    _addToCalendar();
                  },
                  child: Text(
                    'Add to Calendar',
                    style: TextStyle(
                      color: isDarkMode
                          ? TColors.lightBlue
                          : TColors.buttonPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }

  // Add to Calendar (placeholder)
  void _addToCalendar() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meeting added to calendar'),
        backgroundColor: TColors.buttonPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
