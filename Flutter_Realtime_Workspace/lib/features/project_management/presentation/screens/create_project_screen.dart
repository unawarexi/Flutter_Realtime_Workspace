import 'package:flutter/material.dart';
import 'package:flutter_realtime_workspace/core/utils/helpers/helper_functions.dart';
import 'package:flutter_realtime_workspace/features/project_management/presentation/widgets/project_templates.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen>
    with TickerProviderStateMixin {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _projectKeyController = TextEditingController();
  
  String? _selectedTemplate;
  String? _uploadedFileName;
  bool _isUploading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, String>> _projectTemplates = [
    {
      'name': 'Kanban',
      'description':
          'A Kanban board helps visualize tasks in different stages of completion.',
      'icon': 'assets/images/kanban.png'
    },
    {
      'name': 'Scrum',
      'description':
          'Scrum helps manage tasks efficiently by organizing work into sprints.',
      'icon': 'assets/images/scrum.png'
    },
    {
      'name': 'Blank Project',
      'description': 'Start from scratch with a clean project workspace.',
      'icon': 'assets/images/blank.png'
    },
    {
      'name': 'Project Management',
      'description':
          'Keep track of all your resources and deadlines effectively.',
      'icon': 'assets/images/manage.png'
    },
    {
      'name': 'Task Tracking',
      'description':
          'Track the progress of tasks and assignments in one place.',
      'icon': 'assets/images/track.png'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _projectNameController.dispose();
    _projectDescriptionController.dispose();
    _projectKeyController.dispose();
    super.dispose();
  }

  void _handleTemplateSelected(String? template) {
    setState(() {
      _selectedTemplate = template;
    });
  }

  void _handleFileUpload() async {
    setState(() {
      _isUploading = true;
    });
    
    // Simulate file upload delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isUploading = false;
      _uploadedFileName = 'project_structure.pdf';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0E1A) : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDarkMode),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildProjectForm(isDarkMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF1E293B).withOpacity(0.8)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDarkMode 
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            size: 18,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        'Create Project',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1E40AF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E40AF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.folder_special,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Workspace',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: THelperFunctions.isDarkMode(context) 
                            ? Colors.white 
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set up your project workspace with templates and resources',
                      style: TextStyle(
                        fontSize: 14,
                        color: THelperFunctions.isDarkMode(context) 
                            ? Colors.white70 
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectForm(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Project Details', Icons.info_outline),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _projectNameController,
          label: 'Project Name',
          hint: 'Enter your project name',
          icon: Icons.edit_outlined,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 20),
        _buildModernTextField(
          controller: _projectDescriptionController,
          label: 'Description',
          hint: 'Describe your project goals and objectives',
          icon: Icons.description_outlined,
          maxLines: 3,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 20),
        _buildModernTextField(
          controller: _projectKeyController,
          label: 'Project Key',
          hint: 'e.g., PROJ-001',
          icon: Icons.key_outlined,
          isDarkMode: isDarkMode,
        ),
        const SizedBox(height: 32),
        
        _buildSectionTitle('Template Selection', Icons.dashboard_customize_outlined),
        const SizedBox(height: 16),
        _buildTemplateSection(isDarkMode),
        const SizedBox(height: 32),
        
        _buildSectionTitle('Resources', Icons.upload_file_outlined),
        const SizedBox(height: 16),
        _buildFileUploadSection(isDarkMode),
        const SizedBox(height: 40),
        
        _buildCreateButton(isDarkMode),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final isDarkMode = THelperFunctions.isDarkMode(context);
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF3B82F6),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDarkMode,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 16,
          color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF3B82F6),
            size: 20,
          ),
          labelStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white38 : const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          filled: true,
          fillColor: isDarkMode 
              ? const Color(0xFF1E293B).withOpacity(0.8)
              : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDarkMode 
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDarkMode 
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF3B82F6),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1E293B).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProjectTemplateDropdown(
            projectTemplates: _projectTemplates,
            onTemplateSelected: _handleTemplateSelected,
          ),
          if (_selectedTemplate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selected: $_selectedTemplate',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileUploadSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1E293B).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Project Structure',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PDF, Image, or Video files',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          
          if (_uploadedFileName != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _uploadedFileName!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF64748B),
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _uploadedFileName = null;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          
          InkWell(
            onTap: _isUploading ? null : _handleFileUpload,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: _isUploading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Choose File',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
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

  Widget _buildCreateButton(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Create project logic
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Create Project',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}