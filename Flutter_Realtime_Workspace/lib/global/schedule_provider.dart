import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_realtime_workspace/features/collaboration/domain/apis/schedule_api.dart';

// State for schedule meet
class ScheduleState {
  final dynamic meetings;
  final dynamic meetingDetail;
  final bool isLoading;
  final String? error;

  ScheduleState({
    this.meetings,
    this.meetingDetail,
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    dynamic meetings,
    dynamic meetingDetail,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      meetings: meetings ?? this.meetings,
      meetingDetail: meetingDetail ?? this.meetingDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(ScheduleState());

  // Fetch all meetings (with optional filters)
  Future<void> fetchMeetings({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await ScheduleApi.getAllMeetings(params: params);
      state = state.copyWith(meetings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(meetings: null, isLoading: false, error: e.toString());
    }
  }

  // Fetch meeting by ID
  Future<void> fetchMeetingById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await ScheduleApi.getMeetingById(id);
      state = state.copyWith(meetingDetail: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(meetingDetail: null, isLoading: false, error: e.toString());
    }
  }

  // Create a new meeting
  Future<dynamic> createMeeting(dynamic data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ScheduleApi.createMeeting(data);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Update a meeting
  Future<dynamic> updateMeeting(String id, dynamic data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ScheduleApi.updateMeeting(id, data);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Delete a meeting
  Future<dynamic> deleteMeeting(String id, {dynamic data}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ScheduleApi.deleteMeeting(id, data: data);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Fetch user's meetings
  Future<void> fetchUserMeetings(String userId, {Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await ScheduleApi.getUserMeetings(userId, params: params);
      state = state.copyWith(meetings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(meetings: null, isLoading: false, error: e.toString());
    }
  }

  // Fetch today's meetings for a user
  Future<void> fetchTodaysMeetings(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await ScheduleApi.getTodaysMeetings(userId);
      state = state.copyWith(meetings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(meetings: null, isLoading: false, error: e.toString());
    }
  }

  // Fetch upcoming meetings for a user
  Future<void> fetchUpcomingMeetings(String userId, {int limit = 10}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await ScheduleApi.getUpcomingMeetings(userId, limit: limit);
      state = state.copyWith(meetings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(meetings: null, isLoading: false, error: e.toString());
    }
  }

  // Fetch meeting templates
  Future<void> fetchMeetingTemplates({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await ScheduleApi.getMeetingTemplates(params: params);
      state = state.copyWith(meetings: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(meetings: null, isLoading: false, error: e.toString());
    }
  }

  // Add more methods as needed for other endpoints...
}

// Provider for schedule meet
final scheduleProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(),
);
