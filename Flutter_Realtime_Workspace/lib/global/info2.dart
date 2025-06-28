// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../features/authentication/domain/apis/user_info_api.dart';

// // UserInfo State Management
// class UserInfoState {
//   final Map<String, dynamic>? data;
//   final bool isLoading;
//   final String? error;
//   final bool isInitialized;

//   const UserInfoState({
//     this.data,
//     this.isLoading = false,
//     this.error,
//     this.isInitialized = false,
//   });

//   UserInfoState copyWith({
//     Map<String, dynamic>? data,
//     bool? isLoading,
//     Object? error = _sentinel,
//     bool? isInitialized,
//   }) {
//     return UserInfoState(
//       data: data ?? this.data,
//       isLoading: isLoading ?? this.isLoading,
//       error: identical(error, _sentinel)
//           ? this.error
//           : (error == null ? null : error as String?),
//       isInitialized: isInitialized ?? this.isInitialized,
//     );
//   }
//   static const _sentinel = Object();

//   // Helper methods to safely access nested data
//   String get fullName => _getString('fullName');
//   String get displayName => _getString('displayName');
//   String get email => _getString('email');
//   String get profilePicture => _getString('profilePicture');
//   String get phoneNumber => _getString('phoneNumber');
//   String get roleTitle => _getString('roleTitle');
//   String get department => _getString('department');
//   String get workType => _getString('workType');
//   String get timezone => _getString('timezone');
//   String get companyName => _getString('companyName');
//   String get companyWebsite => _getString('companyWebsite');
//   String get industry => _getString('industry');
//   String get teamSize => _getString('teamSize');
//   String get officeLocation => _getString('officeLocation');
//   String get inviteCode => _getString('inviteCode');
//   String get teamProjectName => _getString('teamProjectName');
//   String get permissionsLevel => _getString('permissionsLevel');
//   String get bio => _getString('bio');
  
//   // Working hours
//   String get workingHoursStart => _getNestedString('workingHours', 'start');
//   String get workingHoursEnd => _getNestedString('workingHours', 'end');
  
//   // Social links
//   String get linkedInUrl => _getNestedString('socialLinks', 'linkedIn');
//   String get githubUrl => _getNestedString('socialLinks', 'github');
  
//   // Lists
//   List<String> get interestsSkills => _getStringList('interestsSkills');
//   List<String> get referredTo => _getStringList('referredTo');
  
//   // Booleans
//   bool get isVerified => _getBool('isVerified');
  
//   // Numbers
//   int get profileCompletion => _getInt('profileCompletion');
  
//   // Helper methods for safe data access
//   String _getString(String key) {
//     try {
//       final value = data?[key];
//       if (value == null) return '';
//       return value.toString();
//     } catch (e) {
//       print('[UserInfoState] Error getting string for key $key: $e');
//       return '';
//     }
//   }
  
//   String _getNestedString(String parentKey, String childKey) {
//     try {
//       final parent = data?[parentKey];
//       if (parent == null || parent is! Map) return '';
//       final value = parent[childKey];
//       if (value == null) return '';
//       return value.toString();
//     } catch (e) {
//       print('[UserInfoState] Error getting nested string for $parentKey.$childKey: $e');
//       return '';
//     }
//   }
  
//   List<String> _getStringList(String key) {
//     try {
//       final value = data?[key];
//       if (value == null) return [];
//       if (value is List) {
//         return value.map((item) => item.toString()).toList();
//       }
//       return [];
//     } catch (e) {
//       print('[UserInfoState] Error getting string list for key $key: $e');
//       return [];
//     }
//   }
  
//   bool _getBool(String key) {
//     try {
//       final value = data?[key];
//       if (value == null) return false;
//       if (value is bool) return value;
//       if (value is String) return value.toLowerCase() == 'true';
//       return false;
//     } catch (e) {
//       print('[UserInfoState] Error getting bool for key $key: $e');
//       return false;
//     }
//   }
  
//   int _getInt(String key) {
//     try {
//       final value = data?[key];
//       if (value == null) return 0;
//       if (value is int) return value;
//       if (value is num) return value.toInt();
//       if (value is String) return int.tryParse(value) ?? 0;
//       return 0;
//     } catch (e) {
//       print('[UserInfoState] Error getting int for key $key: $e');
//       return 0;
//     }
//   }
// }

// class UserInfoNotifier extends StateNotifier<UserInfoState> {
//   UserInfoNotifier() : super(const UserInfoState());

//   /// Normalize and validate data before sending to backend
//   Map<String, dynamic> _normalizeUserData(Map<String, dynamic> rawData) {
//     final normalized = <String, dynamic>{};
    
//     print('[UserInfoProvider] Normalizing raw data: $rawData');
    
//     // Handle basic string fields
//     final stringFields = [
//       'fullName', 'displayName', 'email', 'phoneNumber', 'roleTitle',
//       'department', 'workType', 'timezone', 'companyName', 'companyWebsite',
//       'industry', 'teamSize', 'officeLocation', 'inviteCode', 
//       'teamProjectName', 'permissionsLevel', 'bio'
//     ];
    
//     for (final field in stringFields) {
//       final value = rawData[field];
//       if (value != null && value.toString().trim().isNotEmpty) {
//         normalized[field] = value.toString().trim();
//       }
//     }
    
//     // Handle integer fields
//     final intFields = ['profileCompletion'];
//     for (final field in intFields) {
//       final value = rawData[field];
//       if (value != null) {
//         if (value is int) {
//           normalized[field] = value;
//         } else if (value is String) {
//           final parsed = int.tryParse(value);
//           if (parsed != null) {
//             normalized[field] = parsed;
//           }
//         }
//       }
//     }
    
//     // Handle boolean fields
//     final boolFields = ['isVerified'];
//     for (final field in boolFields) {
//       final value = rawData[field];
//       if (value != null) {
//         if (value is bool) {
//           normalized[field] = value;
//         } else if (value is String) {
//           normalized[field] = value.toLowerCase() == 'true';
//         }
//       }
//     }
    
//     // Handle array fields
//     final arrayFields = ['interestsSkills', 'referredTo'];
//     for (final field in arrayFields) {
//       final value = rawData[field];
//       if (value != null && value is List) {
//         final cleanList = value
//             .where((item) => item != null && item.toString().trim().isNotEmpty)
//             .map((item) => item.toString().trim())
//             .toList();
//         if (cleanList.isNotEmpty) {
//           normalized[field] = cleanList;
//         }
//       }
//     }
    
//     // Handle nested objects - Working Hours
//     if (rawData['workingHours'] != null || 
//         rawData['workingHoursStart'] != null || 
//         rawData['workingHoursEnd'] != null) {
      
//       final workingHours = <String, dynamic>{};
      
//       // Check if already nested
//       if (rawData['workingHours'] is Map) {
//         final existing = rawData['workingHours'] as Map;
//         if (existing['start'] != null && existing['start'].toString().trim().isNotEmpty) {
//           workingHours['start'] = existing['start'].toString().trim();
//         }
//         if (existing['end'] != null && existing['end'].toString().trim().isNotEmpty) {
//           workingHours['end'] = existing['end'].toString().trim();
//         }
//       } else {
//         // Handle flat structure
//         if (rawData['workingHoursStart'] != null && 
//             rawData['workingHoursStart'].toString().trim().isNotEmpty) {
//           workingHours['start'] = rawData['workingHoursStart'].toString().trim();
//         }
//         if (rawData['workingHoursEnd'] != null && 
//             rawData['workingHoursEnd'].toString().trim().isNotEmpty) {
//           workingHours['end'] = rawData['workingHoursEnd'].toString().trim();
//         }
//       }
      
//       if (workingHours.isNotEmpty) {
//         normalized['workingHours'] = workingHours;
//       }
//     }
    
//     // Handle nested objects - Social Links
//     if (rawData['socialLinks'] != null || 
//         rawData.keys.any((key) => key.startsWith('socialLinks['))) {
      
//       final socialLinks = <String, dynamic>{};
      
//       // Check if already nested
//       if (rawData['socialLinks'] is Map) {
//         final existing = rawData['socialLinks'] as Map;
//         if (existing['linkedIn'] != null && existing['linkedIn'].toString().trim().isNotEmpty) {
//           socialLinks['linkedIn'] = existing['linkedIn'].toString().trim();
//         }
//         if (existing['github'] != null && existing['github'].toString().trim().isNotEmpty) {
//           socialLinks['github'] = existing['github'].toString().trim();
//         }
//       } else {
//         // Handle flat structure with keys like 'socialLinks[linkedIn]'
//         for (final entry in rawData.entries) {
//           if (entry.key.startsWith('socialLinks[') && entry.key.endsWith(']')) {
//             final platform = entry.key.substring(12, entry.key.length - 1); // Remove 'socialLinks[' and ']'
//             if (entry.value != null && entry.value.toString().trim().isNotEmpty) {
//               socialLinks[platform] = entry.value.toString().trim();
//             }
//           }
//         }
        
//         // Also check for direct keys
//         if (rawData['linkedIn'] != null && rawData['linkedIn'].toString().trim().isNotEmpty) {
//           socialLinks['linkedIn'] = rawData['linkedIn'].toString().trim();
//         }
//         if (rawData['github'] != null && rawData['github'].toString().trim().isNotEmpty) {
//           socialLinks['github'] = rawData['github'].toString().trim();
//         }
//       }
      
//       if (socialLinks.isNotEmpty) {
//         normalized['socialLinks'] = socialLinks;
//       }
//     }
    
//     print('[UserInfoProvider] Normalized data: $normalized');
//     return normalized;
//   }

//   // Load user info from backend
//   Future<void> load() async {
//     if (state.isLoading) return;
    
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       print('[UserInfoProvider] Loading user info...');
//       final data = await UserApi.getMyUserInfo();
//       print('[UserInfoProvider] Successfully loaded user info: $data');
      
//       state = state.copyWith(
//         data: data,
//         isLoading: false,
//         error: null,
//         isInitialized: true,
//       );
//     } catch (e) {
//       print('[UserInfoProvider] Error loading user info: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//         isInitialized: true,
//       );
//     }
//   }

//   // Save user info to backend
//   Future<void> save(Map<String, dynamic> userInfoData, {String? imagePath}) async {
//     if (state.isLoading) return;
    
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       print('[UserInfoProvider] Saving user info...');
//       print('[UserInfoProvider] Raw data to save: $userInfoData');
//       print('[UserInfoProvider] Image path: $imagePath');
      
//       // Normalize the data before sending
//       final normalizedData = _normalizeUserData(userInfoData);
//       print('[UserInfoProvider] Normalized data to save: $normalizedData');
      
//       final savedData = await UserApi.createOrUpdateMyUserInfo(
//         normalizedData,
//         imagePath: imagePath,
//       );
      
//       print('[UserInfoProvider] Successfully saved user info: $savedData');
      
//       state = state.copyWith(
//         data: savedData,
//         isLoading: false,
//         error: null,
//         isInitialized: true,
//       );
//     } catch (e) {
//       print('[UserInfoProvider] Error saving user info: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }

//   // Update user info
//   Future<void> update(Map<String, dynamic> userInfoData, {String? imagePath}) async {
//     if (state.isLoading) return;
    
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       print('[UserInfoProvider] Updating user info...');
//       print('[UserInfoProvider] Raw data to update: $userInfoData');
//       print('[UserInfoProvider] Image path: $imagePath');
      
//       // Normalize the data before sending
//       final normalizedData = _normalizeUserData(userInfoData);
//       print('[UserInfoProvider] Normalized data to update: $normalizedData');
      
//       final updatedData = await UserApi.updateMyUserInfo(
//         normalizedData,
//         imagePath: imagePath,
//       );
      
//       print('[UserInfoProvider] Successfully updated user info: $updatedData');
      
//       state = state.copyWith(
//         data: updatedData,
//         isLoading: false,
//         error: null,
//         isInitialized: true,
//       );
//     } catch (e) {
//       print('[UserInfoProvider] Error updating user info: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }

//   // Upload profile picture only
//   Future<void> uploadProfilePicture(String imagePath) async {
//     if (state.isLoading) return;
    
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       print('[UserInfoProvider] Uploading profile picture...');
//       print('[UserInfoProvider] Image path: $imagePath');
      
//       final updatedData = await UserApi.uploadProfilePicture(imagePath);
      
//       print('[UserInfoProvider] Successfully uploaded profile picture: $updatedData');
      
//       // Merge the updated data with existing data
//       final mergedData = {...?state.data, ...updatedData};
      
//       state = state.copyWith(
//         data: mergedData,
//         isLoading: false,
//         error: null,
//       );
//     } catch (e) {
//       print('[UserInfoProvider] Error uploading profile picture: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }

//   // Regenerate invite code
//   Future<void> regenerateInviteCode() async {
//     if (state.isLoading) return;
    
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       print('[UserInfoProvider] Regenerating invite code...');
      
//       final updatedData = await UserApi.regenerateInviteCode();
      
//       print('[UserInfoProvider] Successfully regenerated invite code: $updatedData');
      
//       // Merge the updated data with existing data
//       final mergedData = {...?state.data, ...updatedData};
      
//       state = state.copyWith(
//         data: mergedData,
//         isLoading: false,
//         error: null,
//       );
//     } catch (e) {
//       print('[UserInfoProvider] Error regenerating invite code: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }

//   // Delete user info
//   Future<void> delete() async {
//     if (state.isLoading) return;
    
//     state = state.copyWith(isLoading: true, error: null);
    
//     try {
//       print('[UserInfoProvider] Deleting user info...');
      
//       await UserApi.deleteMyUserInfo();
      
//       print('[UserInfoProvider] Successfully deleted user info');
      
//       state = state.copyWith(
//         data: null,
//         isLoading: false,
//         error: null,
//         isInitialized: true,
//       );
//     } catch (e) {
//       print('[UserInfoProvider] Error deleting user info: $e');
//       state = state.copyWith(
//         isLoading: false,
//         error: e.toString(),
//       );
//     }
//   }

//   // Fetch all users (admin function)
//   Future<void> fetchAll() async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final users = await UserApi.getAllUserInfos();
//       state = state.copyWith(data: {'users': users}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   // Fetch user by ID
//   Future<void> fetchById(String id) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final user = await UserApi.getUserInfoById(id);
//       state = state.copyWith(data: user, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   // Revoke referral code
//   Future<void> revokeReferralCode(String id) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result = await UserApi.revokeUserReferralCode(id);
//       state = state.copyWith(data: {...?state.data, ...result}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   // Update invite permissions
//   Future<void> updateInvitePermissions(String id, Map<String, dynamic> invitePermissions) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result = await UserApi.updateInvitePermissions(id, invitePermissions);
//       state = state.copyWith(data: {...?state.data, ...result}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   // Clear error
//   void clearError() {
//     if (state.error != null) {
//       state = state.copyWith(error: null);
//     }
//   }

//   // Reset state
//   void reset() {
//     state = const UserInfoState();
//   }

//   // Update specific field locally (for optimistic updates)
//   void updateField(String key, dynamic value) {
//     if (state.data != null) {
//       final updatedData = {...state.data!};
//       updatedData[key] = value;
//       state = state.copyWith(data: updatedData);
//     }
//   }

//   // Update nested field locally
//   void updateNestedField(String parentKey, String childKey, dynamic value) {
//     if (state.data != null) {
//       final updatedData = {...state.data!};
      
//       // Ensure parent object exists
//       if (updatedData[parentKey] == null || updatedData[parentKey] is! Map) {
//         updatedData[parentKey] = <String, dynamic>{};
//       }
      
//       // Update the nested field
//       final parentMap = Map<String, dynamic>.from(updatedData[parentKey]);
//       parentMap[childKey] = value;
//       updatedData[parentKey] = parentMap;
      
//       state = state.copyWith(data: updatedData);
//     }
//   }

//   // Update social links locally
//   void updateSocialLinks(Map<String, String> socialLinks) {
//     if (state.data != null) {
//       final updatedData = {...state.data!};
//       updatedData['socialLinks'] = socialLinks;
//       state = state.copyWith(data: updatedData);
//     }
//   }

//   // Update working hours locally  
//   void updateWorkingHours(String start, String end) {
//     if (state.data != null) {
//       final updatedData = {...state.data!};
//       updatedData['workingHours'] = {
//         'start': start,
//         'end': end,
//       };
//       state = state.copyWith(data: updatedData);
//     }
//   }
// }

// final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfoState>(
//   (ref) => UserInfoNotifier(),
// );