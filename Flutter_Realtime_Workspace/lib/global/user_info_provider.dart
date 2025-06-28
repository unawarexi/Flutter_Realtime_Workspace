// import 'package:flutter_realtime_workspace/core/services/auth_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../features/authentication/domain/apis/user_info_api.dart';

// class UserInfoState {
//   final Map<String, dynamic>? data;
//   final bool isLoading;
//   final String? error;

//   UserInfoState({this.data, this.isLoading = false, this.error});

//   UserInfoState copyWith({
//     Map<String, dynamic>? data,
//     bool? isLoading,
//     String? error,
//   }) {
//     return UserInfoState(
//       data: data ?? this.data,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }

// class UserInfoNotifier extends StateNotifier<UserInfoState> {
//   UserInfoNotifier() : super(UserInfoState());

//   Future<void> fetch() async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final data = await UserApi.getMyUserInfo();
//       state = UserInfoState(data: data, isLoading: false);
//     } catch (e) {
//       state = UserInfoState(data: null, isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> save(Map<String, dynamic> data, {String? imagePath}) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final saved =
//           await UserApi.createOrUpdateMyUserInfo(data, imagePath: imagePath);
//       state = UserInfoState(data: saved, isLoading: false);
//     } catch (e) {
//       state = UserInfoState(data: null, isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> update(Map<String, dynamic> data, {String? imagePath}) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final updated =
//           await UserApi.updateMyUserInfo(data, imagePath: imagePath);
//       state = UserInfoState(data: updated, isLoading: false);
//     } catch (e) {
//       state = UserInfoState(data: null, isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> delete() async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       await UserApi.deleteMyUserInfo();
//       state = UserInfoState(data: null, isLoading: false);
//     } catch (e) {
//       state = UserInfoState(data: null, isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> regenerateInviteCode() async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result = await UserApi.regenerateInviteCode();
//       state =
//           state.copyWith(data: {...?state.data, ...result}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> uploadProfilePicture(String imagePath) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result = await UserApi.uploadProfilePicture(imagePath);
//       state = state.copyWith(
//           data: {...?state.data, ...result['user']}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> fetchAll() async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final users = await UserApi.getAllUserInfos();
//       state = state.copyWith(data: {'users': users}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> fetchById(String id) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final user = await UserApi.getUserInfoById(id);
//       state = state.copyWith(data: user, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> revokeReferralCode(String id) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result = await UserApi.revokeUserReferralCode(id);
//       state =
//           state.copyWith(data: {...?state.data, ...result}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }

//   Future<void> updateInvitePermissions(
//       String id, Map<String, dynamic> invitePermissions) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final result =
//           await UserApi.updateInvitePermissions(id, invitePermissions);
//       state =
//           state.copyWith(data: {...?state.data, ...result}, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, error: e.toString());
//     }
//   }
// }

// final userInfoProvider = StateNotifierProvider<UserInfoNotifier, UserInfoState>(
//   (ref) => UserInfoNotifier(),
// );

// // Provider to fetch user info by id and expose it globally
// final userInfoByIdProvider = FutureProvider.autoDispose
//     .family<Map<String, dynamic>?, String>((ref, id) async {
//   try {
//     final user = await UserApi.getUserInfoById(id);
//     return user;
//   } catch (e) {
//     return null;
//   }
// });

// // Provider to fetch user info by id and expose it globally
// // final userInfoByIdProvider =
// //     FutureProvider.family<Map<String, dynamic>?, String>((ref, id) async {
// //   final currentUserId = AuthService.currentUser?.uid; // Use AuthService
// //   if (currentUserId == null || id != currentUserId) {
// //     // Only allow fetching info for the current user
// //     return null;
// //   }
// //   try {
// //     final user = await UserApi.getUserInfoById(id);
// //     return user;
// //   } catch (e) {
// //     return null;
// //   }
// // });
