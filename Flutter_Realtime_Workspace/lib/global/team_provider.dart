import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_realtime_workspace/features/team_management/domain/apis/team_api.dart';

class TeamState {
  final List<dynamic> teams;
  final dynamic selectedTeam;
  final bool isLoading;
  final String? error;

  TeamState({
    this.teams = const [],
    this.selectedTeam,
    this.isLoading = false,
    this.error,
  });

  TeamState copyWith({
    List<dynamic>? teams,
    dynamic selectedTeam,
    bool? isLoading,
    String? error,
  }) {
    return TeamState(
      teams: teams ?? this.teams,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class TeamNotifier extends StateNotifier<TeamState> {
  TeamNotifier() : super(TeamState());

  Future<void> fetchTeams() async {
    print('[TeamProvider] fetchTeams called');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final teams = await TeamApi.getUserTeams();
      print('[TeamProvider] Teams fetched: ${teams.length}');
      state = state.copyWith(teams: teams, isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] fetchTeams: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createTeam(dynamic data) async {
    print('[TeamProvider] createTeam called with data: $data');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await TeamApi.createTeam(data);
      // If the backend returns { success, message, data }, extract the team from response['data']
      final team = response is Map && response.containsKey('data') ? response['data'] : response;
      final updatedTeams = [...state.teams, team];
      print('[TeamProvider] Team created and added to state');
      state = state.copyWith(teams: updatedTeams, isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] createTeam: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchTeam(String identifier) async {
    print('[TeamProvider] fetchTeam called with identifier: $identifier');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final team = await TeamApi.getTeam(identifier);
      print('[TeamProvider] Team fetched: $team');
      state = state.copyWith(selectedTeam: team, isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] fetchTeam: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateTeam(String teamId, dynamic data) async {
    print('[TeamProvider] updateTeam called for $teamId with data: $data');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await TeamApi.updateTeam(teamId, data);
      final updatedTeams = state.teams.map((t) {
        final id = t['id'] ?? t['_id'];
        return id == teamId ? updated : t;
      }).toList();
      print('[TeamProvider] Team updated in state');
      state = state.copyWith(teams: updatedTeams, isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] updateTeam: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteTeam(String teamId) async {
    print('[TeamProvider] deleteTeam called for $teamId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.deleteTeam(teamId);
      final updatedTeams = state.teams.where((t) {
        final id = t['id'] ?? t['_id'];
        return id != teamId;
      }).toList();
      print('[TeamProvider] Team deleted from state');
      state = state.copyWith(teams: updatedTeams, isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] deleteTeam: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<dynamic>> searchTeams(String query, {int limit = 10, bool includePublic = false}) async {
    print('[TeamProvider] searchTeams called with query: $query');
    try {
      final result = await TeamApi.searchTeams(query, limit: limit, includePublic: includePublic);
      print('[TeamProvider] searchTeams result: ${result.length}');
      return result;
    } catch (e) {
      print('[TeamProvider][ERROR] searchTeams: $e');
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<void> inviteMember(String teamId, dynamic data) async {
    print('[TeamProvider] inviteMember called for $teamId with data: $data');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.inviteMember(teamId, data);
      print('[TeamProvider] Member invited');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] inviteMember: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> acceptInvitation(String token) async {
    print('[TeamProvider] acceptInvitation called with token: $token');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.acceptInvitation(token);
      print('[TeamProvider] Invitation accepted');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] acceptInvitation: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateMemberRole(String teamId, String memberId, String role) async {
    print('[TeamProvider] updateMemberRole called for $teamId/$memberId with role: $role');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.updateMemberRole(teamId, memberId, role);
      print('[TeamProvider] Member role updated');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] updateMemberRole: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> removeMember(String teamId, String memberId) async {
    print('[TeamProvider] removeMember called for $teamId/$memberId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.removeMember(teamId, memberId);
      print('[TeamProvider] Member removed');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] removeMember: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> leaveTeam(String teamId) async {
    print('[TeamProvider] leaveTeam called for $teamId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.leaveTeam(teamId);
      print('[TeamProvider] Left team');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] leaveTeam: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> transferOwnership(String teamId, String newOwnerId) async {
    print('[TeamProvider] transferOwnership called for $teamId to $newOwnerId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.transferOwnership(teamId, newOwnerId);
      print('[TeamProvider] Ownership transferred');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] transferOwnership: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> bulkUpdatePermissions(String teamId, dynamic updates) async {
    print('[TeamProvider] bulkUpdatePermissions called for $teamId with updates: $updates');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.bulkUpdatePermissions(teamId, updates);
      print('[TeamProvider] Bulk permissions updated');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] bulkUpdatePermissions: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<dynamic> getTeamProjects(String teamId, {dynamic query}) async {
    print('[TeamProvider] getTeamProjects called for $teamId with query: $query');
    try {
      final result = await TeamApi.getTeamProjects(teamId, query: query);
      print('[TeamProvider] getTeamProjects result: ${result.length}');
      return result;
    } catch (e) {
      print('[TeamProvider][ERROR] getTeamProjects: $e');
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<void> assignProject(String teamId, String projectId, dynamic memberIds) async {
    print('[TeamProvider] assignProject called for $teamId/$projectId with memberIds: $memberIds');
    state = state.copyWith(isLoading: true, error: null);
    try {
      await TeamApi.assignProject(teamId, projectId, memberIds);
      print('[TeamProvider] Project assigned');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('[TeamProvider][ERROR] assignProject: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<dynamic> getTeamAnalytics(String teamId, {String period = "30d"}) async {
    print('[TeamProvider] getTeamAnalytics called for $teamId with period: $period');
    try {
      final result = await TeamApi.getTeamAnalytics(teamId, period: period);
      print('[TeamProvider] getTeamAnalytics result: $result');
      return result;
    } catch (e) {
      print('[TeamProvider][ERROR] getTeamAnalytics: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<dynamic> getActivityFeed(String teamId, {int limit = 20, int page = 1, String? type}) async {
    print('[TeamProvider] getActivityFeed called for $teamId with limit: $limit, page: $page, type: $type');
    try {
      final result = await TeamApi.getActivityFeed(teamId, limit: limit, page: page, type: type);
      print('[TeamProvider] getActivityFeed result: ${result.length}');
      return result;
    } catch (e) {
      print('[TeamProvider][ERROR] getActivityFeed: $e');
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<dynamic> updateIntegrations(String teamId, dynamic integrations) async {
    print('[TeamProvider] updateIntegrations called for $teamId with integrations: $integrations');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await TeamApi.updateIntegrations(teamId, integrations);
      print('[TeamProvider] Integrations updated');
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      print('[TeamProvider][ERROR] updateIntegrations: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<dynamic> checkPermissions(String teamId) async {
    print('[TeamProvider] checkPermissions called for $teamId');
    try {
      final result = await TeamApi.checkPermissions(teamId);
      print('[TeamProvider] checkPermissions result: $result');
      return result;
    } catch (e) {
      print('[TeamProvider][ERROR] checkPermissions: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

final teamProvider = StateNotifierProvider<TeamNotifier, TeamState>(
  (ref) => TeamNotifier(),
);
