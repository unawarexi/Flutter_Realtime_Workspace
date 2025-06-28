import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_realtime_workspace/features/authentication/domain/apis/user_info_api.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String photoURL;
  final String phoneNumber;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoURL,
    required this.phoneNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
}

// Unified state for both Firebase user and custom API user info
class UserState {
  final UserModel? firebaseUser;
  final Map<String, dynamic>? userInfo; // from custom API
  final bool isLoading;
  final String? error;

  UserState({
    this.firebaseUser,
    this.userInfo,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    UserModel? firebaseUser,
    Map<String, dynamic>? userInfo,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userInfo: userInfo ?? this.userInfo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  // Set Firebase user (used after sign-in)
  void setFirebaseUser(UserModel? user) {
    state = state.copyWith(firebaseUser: user);
  }

  // Fetch user info from custom API
  Future<void> fetchUserInfo() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await UserApi.getMyUserInfo();
      state = state.copyWith(userInfo: data, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(userInfo: null, isLoading: false, error: e.toString());
    }
  }

  // Save (create or update) user info via custom API
  Future<void> saveUserInfo(Map<String, dynamic> data,
      {String? imagePath}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final saved =
          await UserApi.createOrUpdateMyUserInfo(data, imagePath: imagePath);
      state = state.copyWith(userInfo: saved, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(userInfo: null, isLoading: false, error: e.toString());
    }
  }

  // Update user info via custom API
  Future<void> updateUserInfo(Map<String, dynamic> data,
      {String? imagePath}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated =
          await UserApi.updateMyUserInfo(data, imagePath: imagePath);
      state = state.copyWith(userInfo: updated, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(userInfo: null, isLoading: false, error: e.toString());
    }
  }

  // Delete user info via custom API
  Future<void> deleteUserInfo() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await UserApi.deleteMyUserInfo();
      state = state.copyWith(userInfo: null, isLoading: false);
    } catch (e) {
      state =
          state.copyWith(userInfo: null, isLoading: false, error: e.toString());
    }
  }

  // Regenerate invite code
  Future<void> regenerateInviteCode() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await UserApi.regenerateInviteCode();
      state = state.copyWith(
          userInfo: {...?state.userInfo, ...result}, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Upload profile picture
  Future<void> uploadProfilePicture(String imagePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await UserApi.uploadProfilePicture(imagePath);
      state = state.copyWith(
        userInfo: {...?state.userInfo, ...result['user']},
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Fetch all users (admin/utility)
  Future<void> fetchAllUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await UserApi.getAllUserInfos();
      state = state.copyWith(userInfo: {'users': users}, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Fetch user info by id (admin/utility)
  Future<void> fetchUserInfoById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await UserApi.getUserInfoById(id);
      state = state.copyWith(userInfo: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Revoke referral code for a user (admin)
  Future<void> revokeReferralCode(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await UserApi.revokeUserReferralCode(id);
      state = state.copyWith(
          userInfo: {...?state.userInfo, ...result}, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Update invite permissions for a user (admin)
  Future<void> updateInvitePermissions(
      String id, Map<String, dynamic> invitePermissions) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result =
          await UserApi.updateInvitePermissions(id, invitePermissions);
      state = state.copyWith(
          userInfo: {...?state.userInfo, ...result}, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Unified provider for both Firebase user and custom API user info
final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);

// Optionally, expose a provider to fetch user info by id (for admin/utility)
final userInfoByIdProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, id) async {
  try {
    final user = await UserApi.getUserInfoById(id);
    return user;
  } catch (e) {
    return null;
  }
});
