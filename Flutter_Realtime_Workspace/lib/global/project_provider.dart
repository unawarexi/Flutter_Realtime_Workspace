import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_realtime_workspace/features/project_management/domain/apis/project_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectState {
  final Map<String, dynamic>? project;
  final List<Map<String, dynamic>>? projects;
  final bool isLoading;
  final String? error;

  ProjectState({
    this.project,
    this.projects,
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    Map<String, dynamic>? project,
    List<Map<String, dynamic>>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      project: project ?? this.project,
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier() : super(ProjectState());

  // Get current user ID
  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Create project with proper data structure
  Future<void> createProject(Map<String, dynamic> data,
      {List<String>? filePaths}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('[ProjectProvider] Creating project...');

      // Ensure we have the current user ID
      final currentUserId = _getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Prepare the project data with required fields
      final projectData = <String, dynamic>{
        'name': data['name']?.toString().trim() ?? '',
        'description': data['description']?.toString().trim() ?? '',
        'key': data['key']?.toString().trim() ?? '',
        'template': data['template']?.toString() ?? 'Kanban',
        'teamId': data['teamId']?.toString().trim() ?? '',
        'createdBy': currentUserId,
        'status': 'active',
        'priority': 'medium',
        'progress': 0,
        'isActive': true,
        'archived': false,
        'completed': false,
        'recent': false,
        'starred': false,
      };

      // Validate required fields
      if (projectData['name'].isEmpty) {
        throw Exception('Project name is required');
      }
      if (projectData['teamId'].isEmpty) {
        throw Exception('Team ID is required');
      }
      if (projectData['key'].isEmpty) {
        throw Exception('Project key is required');
      }

      print('[ProjectProvider] Project data to send: $projectData');

      final created =
          await ProjectApi.createProject(projectData, filePaths: filePaths);
      state = state.copyWith(project: created, isLoading: false);
      print(
          '[ProjectProvider] Project created successfully: ${created['_id']}');
    } catch (e) {
      print('[ProjectProvider][ERROR] createProject: $e');
      state =
          state.copyWith(project: null, isLoading: false, error: e.toString());
      rethrow; // Re-throw to allow UI to handle the error
    }
  }

  // Fetch all projects
  Future<void> fetchProjects({String? teamId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('[ProjectProvider] Fetching projects...');
      final projects = await ProjectApi.getProjects(teamId: teamId);
      state = state.copyWith(projects: projects, isLoading: false);
      print('[ProjectProvider] Projects fetched: ${projects.length}');
    } catch (e) {
      print('[ProjectProvider][ERROR] fetchProjects: $e');
      state =
          state.copyWith(projects: [], isLoading: false, error: e.toString());
    }
  }

  // Fetch project by id
  Future<void> fetchProjectById(String id) async {
    if (id.isEmpty) {
      state = state.copyWith(error: 'Project ID is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      print('[ProjectProvider] Fetching project by id: $id');
      final project = await ProjectApi.getProjectById(id);
      state = state.copyWith(project: project, isLoading: false);
      print('[ProjectProvider] Project fetched: ${project['_id']}');
    } catch (e) {
      print('[ProjectProvider][ERROR] fetchProjectById: $e');
      state =
          state.copyWith(project: null, isLoading: false, error: e.toString());
    }
  }

  // Generate new project key
  Future<String> fetchNewProjectKey() async {
    try {
      print('[ProjectProvider] Generating new project key...');
      final data = await ProjectApi.getNewProjectKey();
    
      final key = data['projectKey'] as String? ?? '';

      if (key.isEmpty) {
        throw Exception('Received empty project key from server');
      }
      print('[ProjectProvider] New project key: $key');
      return key;
    } catch (e) {
      print('[ProjectProvider][ERROR] fetchNewProjectKey: $e');
      throw Exception('Failed to generate project key: ${e.toString()}');
    }
  }

  // Generate new team id
  Future<String> fetchNewTeamId() async {
    try {
      print('[ProjectProvider] Generating new team id...');
      final id = await ProjectApi.getNewTeamId();
      if (id.isEmpty) {
        throw Exception('Received empty team ID from server');
      }
      print('[ProjectProvider] New team id: $id');
      return id;
    } catch (e) {
      print('[ProjectProvider][ERROR] fetchNewTeamId: $e');
      throw Exception('Failed to generate team ID: ${e.toString()}');
    }
  }

  // Update project
  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await ProjectApi.updateProject(id, data);
      state = state.copyWith(project: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Delete project
  Future<void> deleteProject(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ProjectApi.deleteProject(id);
      state = state.copyWith(project: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Toggle project star
  Future<Map<String, dynamic>?> toggleProjectStar(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.toggleProjectStar(id);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Toggle project archive
  Future<Map<String, dynamic>?> toggleProjectArchive(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.toggleProjectArchive(id);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Update project progress
  Future<Map<String, dynamic>?> updateProjectProgress(String id, double progress) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.updateProjectProgress(id, progress);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Duplicate project
  Future<Map<String, dynamic>?> duplicateProject(String id, {String? name, bool includeAttachments = false, String? key}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.duplicateProject(id, name: name, includeAttachments: includeAttachments, key: key);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Update project collaborators
  Future<Map<String, dynamic>?> updateProjectCollaborators(String id, List<String> collaboratorIds, {String action = "add"}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.updateProjectCollaborators(id, collaboratorIds, action: action);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Upload attachment
  Future<Map<String, dynamic>?> uploadAttachment(String id, String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.uploadAttachment(id, filePath);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Get project attachments
  Future<List<Map<String, dynamic>>> getProjectAttachments(String id, {String? type, int page = 1, int limit = 10}) async {
    try {
      return await ProjectApi.getProjectAttachments(id, type: type, page: page, limit: limit);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  // Delete attachment
  Future<void> deleteAttachment(String id, String attachmentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ProjectApi.deleteAttachment(id, attachmentId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Add timeline event
  Future<Map<String, dynamic>?> addTimelineEvent(String id, String title, {String? description, String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await ProjectApi.addTimelineEvent(id, title, description: description, type: type);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Get project timeline
  Future<List<Map<String, dynamic>>> getProjectTimeline(String id, {int page = 1, int limit = 20, String? type}) async {
    try {
      return await ProjectApi.getProjectTimeline(id, page: page, limit: limit, type: type);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  // Get project stats
  Future<Map<String, dynamic>?> getProjectStats({String? teamId}) async {
    try {
      return await ProjectApi.getProjectStats(teamId: teamId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Clear current project
  void clearProject() {
    state = state.copyWith(project: null, error: null);
  }

  // Clear all projects
  void clearProjects() {
    state = state.copyWith(projects: [], error: null);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>(
  (ref) => ProjectNotifier(),
);
