import 'package:flutter/material.dart';
import 'package:flutter_realtime_workspace/core/network/pull_refresh.dart';
import 'package:flutter_realtime_workspace/features/authentication/presentation/widgets/options_screen.dart';
import 'package:flutter_realtime_workspace/global/user_provider.dart';
import 'package:flutter_realtime_workspace/shared/styles/colors.dart';
import 'package:flutter_realtime_workspace/features/authentication/presentation/user_information.dart';
import 'package:flutter_realtime_workspace/core/services/auth_service.dart';
import 'package:flutter_realtime_workspace/features/authentication/presentation/login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final String userId;

  const AccountScreen({
    super.key,
    required this.userId,
    UserModel? user,
  });

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _profileAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Color scheme
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color backgroundLight = Color(0xFFFAFBFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  String _bio = "";
  bool _editingBio = false;
  final TextEditingController _bioController = TextEditingController();

  // Add this getter back for use in all widget methods
  bool get isDarkMode => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _profileAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _profileAnimationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Add pull-to-refresh handler
  Future<void> _onRefresh() async {
    final userState = ref.read(userProvider);
    final currentUid = userState.userInfo?['_id'] ?? '';
    if (widget.userId == currentUid) {
      // Refresh current user info
      await ref.read(userProvider.notifier).fetchUserInfo();
    } else {
      // Refresh other user's info
      ref.refresh(userInfoByIdProvider(widget.userId));
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this is the current user
    final userState = ref.watch(userProvider);
    final currentUid = userState.userInfo?['_id'] ?? '';
    final isCurrentUser = widget.userId == currentUid;

    // Use userProvider for current user, userInfoByIdProvider for others
    final userInfoAsync = isCurrentUser
        ? AsyncValue.data(userState.userInfo)
        : ref.watch(userInfoByIdProvider(widget.userId));

    return userInfoAsync.when(
      data: (user) {
        // Use fallback values for missing data
        final email = user?['email'] ?? 'Not available';
        final displayName = user?['displayName'] ?? 'Not available';
        final companyName = user?['companyName'] ?? 'Not available';
        final profilePicture = user?['profilePicture'] ?? '';
        final bio = user?['bio'] ??
            "This is your bio. Tap to edit and let your team know more about you!";
        final roleTitle = user?['roleTitle'] ?? 'Not available';
        final department = user?['department'] ?? 'Not available';
        final phoneNumber = user?['phoneNumber'] ?? 'Not available';
        final officeLocation = user?['officeLocation'] ?? 'Not available';
        final teamProjectName = user?['teamProjectName'] ?? 'Not available';
        final teamSize = user?['teamSize'] ?? 'Not available';
        final workType = user?['workType'] ?? 'Not available';
        final timezone = user?['timezone'] ?? 'Not available';
        final profileCompletion = user?['profileCompletion'] ?? 0;
        final inviteCode = user?['inviteCode'] ?? 'Not available';
        final invitePermissions = user?['invitePermissions'] ?? {};
        final socialLinks = user?['socialLinks'] ?? {};
        final industry = user?['industry'] ?? 'Not available';
        final companyWebsite = user?['companyWebsite'] ?? 'Not available';
        final interestsSkills = user?['interestsSkills'] ?? [];
        final workingHours = user?['workingHours'] ?? {};

        if (!_editingBio) {
          _bio = bio;
          _bioController.text = bio;
        }

        return Scaffold(
          backgroundColor:
              isDarkMode ? TColors.backgroundDarkAlt : TColors.backgroundLight,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              // --- Wrap main scrollable content with AdvancedPullRefresh ---
              child: AdvancedPullRefresh(
                onRefresh: _onRefresh,
                child: Column(
                  children: [
                    // Fixed AppBar Row
                    Material(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      color: isDarkMode ? backgroundDark : backgroundLight,
                      elevation: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 0, right: 0, bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Back Icon
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new,
                                    color:
                                        isDarkMode ? Colors.white : textPrimary,
                                    size: 22),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              // Profile Picture
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, right: 14),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: profilePicture.isNotEmpty
                                      ? NetworkImage(profilePicture)
                                      : const AssetImage(
                                              "assets/images/avatar.png")
                                          as ImageProvider,
                                  backgroundColor: primaryBlue.withOpacity(0.1),
                                  child: profilePicture.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: primaryBlue,
                                          size: 40,
                                        )
                                      : null,
                                ),
                              ),
                              // Texts
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? lightBlue
                                              : primaryBlue,
                                        ),
                                      ),
                                      Text(
                                        roleTitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Optionally, add a menu button here if needed
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Complete Your Profile Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child:
                          _buildCompleteProfileCard(context, profileCompletion),
                    ),
                    // Main scrollable content
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 0),
                              child: Column(
                                children: [
                                  _buildProfileAndActionsCard(
                                      context,
                                      email,
                                      companyName,
                                      teamProjectName,
                                      teamSize,
                                      department,
                                      officeLocation,
                                      phoneNumber,
                                      workType,
                                      timezone,
                                      industry,
                                      companyWebsite,
                                      inviteCode,
                                      invitePermissions,
                                      socialLinks,
                                      interestsSkills,
                                      workingHours),
                                  const SizedBox(height: 18),
                                  _buildBioSection(context, isDarkMode),
                                  const SizedBox(height: 32),
                                  _buildSettingsSection(),
                                  const SizedBox(height: 32),
                                  _buildSupportSection(),
                                  const SizedBox(height: 32),
                                  _buildSignOutSection(context),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) {
        // Show the screen with all fields as "Not available"
        final fallback = 'Not available';
        return Scaffold(
          backgroundColor:
              isDarkMode ? TColors.backgroundDarkAlt : TColors.backgroundLight,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              // --- Wrap error state with AdvancedPullRefresh too ---
              child: AdvancedPullRefresh(
                onRefresh: _onRefresh,
                child: Column(
                  children: [
                    Material(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      color: isDarkMode ? backgroundDark : backgroundLight,
                      elevation: 0,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 20, left: 0, right: 0, bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new,
                                    color:
                                        isDarkMode ? Colors.white : textPrimary,
                                    size: 22),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 0, right: 14),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: const AssetImage(
                                      "assets/images/avatar.png"),
                                  backgroundColor: primaryBlue.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: primaryBlue,
                                    size: 40,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      Text(
                                        fallback,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode
                                              ? lightBlue
                                              : primaryBlue,
                                        ),
                                      ),
                                      Text(
                                        fallback,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDarkMode
                                              ? Colors.white70
                                              : textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: _buildCompleteProfileCard(context, 0),
                    ),
                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 0),
                              child: Column(
                                children: [
                                  _buildProfileAndActionsCard(
                                    context,
                                    fallback, // email
                                    fallback, // companyName
                                    fallback, // teamProjectName
                                    fallback, // teamSize
                                    fallback, // department
                                    fallback, // officeLocation
                                    fallback, // phoneNumber
                                    fallback, // workType
                                    fallback, // timezone
                                    fallback, // industry
                                    fallback, // companyWebsite
                                    fallback, // inviteCode
                                    <String,
                                        dynamic>{}, // invitePermissions (Map)
                                    <String, dynamic>{}, // socialLinks (Map)
                                    <dynamic>[], // interestsSkills (List)
                                    <String, dynamic>{}, // workingHours (Map)
                                  ),
                                  const SizedBox(height: 18),
                                  _buildBioSection(context, isDarkMode),
                                  const SizedBox(height: 32),
                                  _buildSettingsSection(),
                                  const SizedBox(height: 32),
                                  _buildSupportSection(),
                                  const SizedBox(height: 32),
                                  _buildSignOutSection(context),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompleteProfileCard(
      BuildContext context, int profileCompletion) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isDarkMode ? cardDark : cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? borderDark : borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.06)
                  : Colors.grey.withOpacity(0.03),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_turned_in_rounded,
                color: Colors.orange, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Profile completion: $profileCompletion%",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: profileCompletion / 100.0,
                    backgroundColor: Colors.grey[300],
                    color: Colors.orange,
                    minHeight: 5,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: isDarkMode ? Colors.white54 : textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAndActionsCard(
    BuildContext context,
    String email,
    String companyName,
    String teamProjectName,
    String teamSize,
    String department,
    String officeLocation,
    String phoneNumber,
    String workType,
    String timezone,
    String industry,
    String companyWebsite,
    String inviteCode,
    Map invitePermissions,
    Map socialLinks,
    List interestsSkills,
    Map workingHours,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? cardDark : cardLight,
          borderRadius: BorderRadius.circular(18), // reduced
          border: Border.all(
            color: isDarkMode ? borderDark : borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.08)
                  : Colors.grey.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 14, horizontal: 10), // reduced
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                email,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primaryBlue.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  companyName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Add more user info here as needed
              Text(
                "Role: $department, $workType",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              Text(
                "Team: $teamProjectName ($teamSize)",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              Text(
                "Location: $officeLocation, $timezone",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              Text(
                "Phone: $phoneNumber",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              Text(
                "Industry: $industry",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              Text(
                "Website: $companyWebsite",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              Text(
                "Invite Code: $inviteCode",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.white70 : textSecondary,
                ),
              ),
              // ...add more fields as needed...
              // ...existing code for action buttons...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.add_location_alt_rounded,
                    label: "Add Sites",
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const OrganisationOptionsScreen())),
                  ),
                  const SizedBox(width: 10),
                  _buildActionButton(
                    icon: Icons.person_add_alt_1_rounded,
                    label: "Invite Team",
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.pushNamed(context, '/invite'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioSection(BuildContext context, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? cardDark : cardLight,
          borderRadius: BorderRadius.circular(14), // reduced
          border: Border.all(
            color: isDarkMode ? borderDark : borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.06)
                  : Colors.grey.withOpacity(0.03),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 10, horizontal: 10), // reduced
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: isDarkMode ? lightBlue : primaryBlue,
                      size: 14), // reduced
                  const SizedBox(width: 5), // reduced
                  Text(
                    "Bio",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12, // reduced
                      color: isDarkMode ? Colors.white : textPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingBio = !_editingBio;
                        _bioController.text = _bio;
                      });
                    },
                    child: Icon(
                      _editingBio ? Icons.close : Icons.edit,
                      color: isDarkMode ? lightBlue : primaryBlue,
                      size: 14, // reduced
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6), // reduced
              _editingBio
                  ? Column(
                      children: [
                        TextFormField(
                          controller: _bioController,
                          maxLines: 2, // reduced
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : textPrimary,
                            fontSize: 11, // reduced
                          ),
                          decoration: InputDecoration(
                            hintText: "Write something about yourself...",
                            hintStyle: TextStyle(
                              color:
                                  isDarkMode ? Colors.white54 : textSecondary,
                              fontSize: 11, // reduced
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8), // reduced
                              borderSide: BorderSide(
                                color: isDarkMode ? borderDark : borderLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8), // reduced
                              borderSide: BorderSide(
                                color: isDarkMode ? lightBlue : primaryBlue,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 8), // reduced
                          ),
                        ),
                        const SizedBox(height: 6), // reduced
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDarkMode ? lightBlue : primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(6), // reduced
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7), // reduced
                              ),
                              onPressed: () {
                                setState(() {
                                  _bio = _bioController.text.trim().isEmpty
                                      ? "This is your bio. Tap to edit and let your team know more about you!"
                                      : _bioController.text.trim();
                                  _editingBio = false;
                                });
                                // Optionally, update bio on backend here
                              },
                              child: const Text("Save",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11)), // reduced
                            ),
                          ],
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 1, bottom: 1),
                      child: Text(
                        _bio,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white70 : textSecondary,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    final settingsItems = [
      {
        'icon': Icons.notifications_none_rounded,
        'title': 'Notifications',
        'subtitle': 'Manage your alerts',
        'route': '/notifications',
      },
      {
        'icon': Icons.settings_rounded,
        'title': 'Preferences',
        'subtitle': 'App settings',
        'route': '/settings',
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Privacy & Security',
        'subtitle': 'Account protection',
        'route': '/privacy',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: TextStyle(
            fontSize: 14, // reduced
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : textPrimary,
          ),
        ),
        const SizedBox(height: 8), // reduced
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? cardDark : cardLight,
            borderRadius: BorderRadius.circular(12), // reduced
            border: Border.all(
              color: isDarkMode ? borderDark : borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.08)
                    : Colors.grey.withOpacity(0.04),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: settingsItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == settingsItems.length - 1;

              return Column(
                children: [
                  _buildSettingsItem(item),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: isDarkMode ? borderDark : borderLight,
                      indent: 40, // reduced
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(Map<String, dynamic> item) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 5), // reduced
      leading: Container(
        padding: const EdgeInsets.all(6), // reduced
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7), // reduced
        ),
        child: Icon(
          item['icon'],
          color: primaryBlue,
          size: 15, // reduced
        ),
      ),
      title: Text(
        item['title'],
        style: TextStyle(
          fontSize: 12, // reduced
          fontWeight: FontWeight.w600,
          color: isDarkMode ? Colors.white : textPrimary,
        ),
      ),
      subtitle: Text(
        item['subtitle'],
        style: TextStyle(
          fontSize: 10, // reduced
          color: isDarkMode ? Colors.white60 : textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 12, // reduced
        color: isDarkMode ? Colors.white70 : textSecondary,
      ),
      onTap: () => Navigator.pushNamed(context, item['route']),
    );
  }

  Widget _buildSupportSection() {
    final supportItems = [
      {
        'icon': Icons.feedback_rounded,
        'title': 'Send Feedback',
        'route': '/feedback',
      },
      {
        'icon': Icons.star_rate_rounded,
        'title': 'Rate App',
        'route': '/rate',
      },
      {
        'icon': Icons.new_releases_rounded,
        'title': "What's New",
        'route': '/whatsnew',
      },
      {
        'icon': Icons.apps_rounded,
        'title': 'More Apps',
        'route': '/moreapps',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support',
          style: TextStyle(
            fontSize: 14, // reduced
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : textPrimary,
          ),
        ),
        const SizedBox(height: 8), // reduced
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? cardDark : cardLight,
            borderRadius: BorderRadius.circular(12), // reduced
            border: Border.all(
              color: isDarkMode ? borderDark : borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.08)
                    : Colors.grey.withOpacity(0.04),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: supportItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == supportItems.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ), // reduced
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isDarkMode ? Colors.white70 : textSecondary,
                      size: 15, // reduced
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: 12, // reduced
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : textPrimary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 12, // reduced
                      color: isDarkMode ? Colors.white70 : textSecondary,
                    ),
                    onTap: () =>
                        Navigator.pushNamed(context, item['route'] as String),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: isDarkMode ? borderDark : borderLight,
                      indent: 40, // reduced
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSignOutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? cardDark : cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? borderDark : borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.08)
                : Colors.grey.withOpacity(0.04),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        onTap: () async {
          await AuthService.signOut();
          // Optionally, confirm tokens are cleared:
          // print('All tokens and user data cleared from storage.');
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Authentication()),
              (route) => false,
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), // reduced
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8), // reduced
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12), // reduced
          border: Border.all(
            color: color.withOpacity(0.13),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 15), // reduced
            const SizedBox(width: 5), // reduced
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 11, // reduced
              ),
            ),
          ],
        ),
      ),
    );
  }
}
