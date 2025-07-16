import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_realtime_workspace/features/authentication/domain/apis/referral_api.dart';

class ReferralState {
  final Map<String, dynamic>? referralData;
  final bool isLoading;
  final String? error;

  ReferralState({
    this.referralData,
    this.isLoading = false,
    this.error,
  });

  ReferralState copyWith({
    Map<String, dynamic>? referralData,
    bool? isLoading,
    String? error,
  }) {
    return ReferralState(
      referralData: referralData ?? this.referralData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReferralNotifier extends StateNotifier<ReferralState> {
  ReferralNotifier() : super(ReferralState());

  // Regenerate invite code
  Future<void> regenerateInviteCode() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ReferralApi.regenerateInviteCode();
      state = state.copyWith(referralData: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Revoke referral code for a user (admin)
  Future<void> revokeReferralCode(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ReferralApi.revokeUserReferralCode(id);
      state = state.copyWith(referralData: result, isLoading: false);
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
          await ReferralApi.updateInvitePermissions(id, invitePermissions);
      state = state.copyWith(referralData: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Add more referral-related methods as needed (e.g., fetchReferralStats, fetchReferralChain)
}

final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>(
  (ref) => ReferralNotifier(),
);
