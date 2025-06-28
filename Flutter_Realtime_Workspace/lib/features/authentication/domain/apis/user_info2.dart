// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_realtime_workspace/core/config/environment.dart';

// class UserApi {
//   static final Dio _dio = Dio(
//     BaseOptions(
//       baseUrl: '${Environment.baseUrl}userinfo',
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       headers: {
//         'Content-Type': 'application/json',
//       },
//     ),
//   );

//   static Future<String> _getToken() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) throw Exception("Not authenticated");
//     final token = await user.getIdToken(true);
//     if (token == null) throw Exception("Failed to retrieve ID token");
//     print('[UserApi] Firebase ID token for user ${user.email}: $token');
//     return token;
//   }

//   // Helper method to safely cast response data
//   static Map<String, dynamic> _safeResponseCast(dynamic responseData) {
//     if (responseData == null) {
//       throw Exception("Response data is null");
//     }
    
//     if (responseData is Map<String, dynamic>) {
//       return responseData;
//     } else if (responseData is Map) {
//       // Convert Map<dynamic, dynamic> to Map<String, dynamic>
//       return Map<String, dynamic>.from(responseData);
//     } else {
//       throw Exception("Invalid response data type: ${responseData.runtimeType}");
//     }
//   }

//   // Helper method to safely cast list response data
//   static List<Map<String, dynamic>> _safeListResponseCast(dynamic responseData) {
//     if (responseData == null) {
//       throw Exception("Response data is null");
//     }
    
//     if (responseData is List<Map<String, dynamic>>) {
//       return responseData;
//     } else if (responseData is List) {
//       return responseData.map((item) {
//         if (item is Map<String, dynamic>) {
//           return item;
//         } else if (item is Map) {
//           return Map<String, dynamic>.from(item);
//         } else {
//           throw Exception("Invalid list item type: ${item.runtimeType}");
//         }
//       }).toList();
//     } else {
//       throw Exception("Invalid response data type: ${responseData.runtimeType}");
//     }
//   }

//   // Get current user's info from backend
//   static Future<Map<String, dynamic>> getMyUserInfo() async {
//     try {
//       final idToken = await _getToken();
//       print('[UserApi] GET /me with token: $idToken');
      
//       final response = await _dio.get(
//         "/me",
//         options: Options(headers: {"Authorization": "Bearer $idToken"}),
//       );
      
//       print('[UserApi] Raw response from /me: ${response.data}');
//       print('[UserApi] Response type: ${response.data.runtimeType}');
      
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from /me: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] getMyUserInfo DioException: ${e.message}');
//       print('[UserApi][ERROR] Response data: ${e.response?.data}');
//       print('[UserApi][ERROR] Status code: ${e.response?.statusCode}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Unknown error occurred';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] getMyUserInfo: $e');
//       rethrow;
//     }
//   }

//   // Create or update (upsert) user info (supports image upload)
//   static Future<Map<String, dynamic>> createOrUpdateMyUserInfo(
//       Map<String, dynamic> data,
//       {String? imagePath}) async {
//     try {
//       final idToken = await _getToken();
      
//       // Clean and validate data before sending
//       final cleanData = _cleanPayloadData(data);
//       print('[UserApi] Cleaned payload data: $cleanData');
      
//       Response response;
//       if (imagePath != null) {
//         final formData = FormData.fromMap({
//           ...cleanData,
//           'profilePicture': await MultipartFile.fromFile(
//             imagePath, 
//             filename: 'profile.jpg'
//           ),
//         });
        
//         print('[UserApi] POST /me (multipart) with token: $idToken, imagePath: $imagePath');
//         print('[UserApi] FormData fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}');
        
//         response = await _dio.post(
//           "/me",
//           data: formData,
//           options: Options(
//             headers: {
//               "Authorization": "Bearer $idToken",
//               "Content-Type": "multipart/form-data",
//             },
//           ),
//         );
//       } else {
//         print('[UserApi] POST /me with token: $idToken, data: $cleanData');
        
//         response = await _dio.post(
//           "/me",
//           data: cleanData,
//           options: Options(
//             headers: {
//               "Authorization": "Bearer $idToken",
//               "Content-Type": "application/json",
//             },
//           ),
//         );
//       }
      
//       print('[UserApi] Raw response from POST /me: ${response.data}');
//       print('[UserApi] Response type: ${response.data.runtimeType}');
      
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from POST /me: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] createOrUpdateMyUserInfo DioException: ${e.message}');
//       print('[UserApi][ERROR] Response data: ${e.response?.data}');
//       print('[UserApi][ERROR] Status code: ${e.response?.statusCode}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to create/update user info';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] createOrUpdateMyUserInfo: $e');
//       rethrow;
//     }
//   }

//   // Update user info (supports image upload)
//   static Future<Map<String, dynamic>> updateMyUserInfo(
//       Map<String, dynamic> data,
//       {String? imagePath}) async {
//     try {
//       final idToken = await _getToken();
      
//       // Clean and validate data before sending
//       final cleanData = _cleanPayloadData(data);
//       print('[UserApi] Cleaned payload data for update: $cleanData');
      
//       Response response;
//       if (imagePath != null) {
//         final formData = FormData.fromMap({
//           ...cleanData,
//           'profilePicture': await MultipartFile.fromFile(
//             imagePath, 
//             filename: 'profile.jpg'
//           ),
//         });
        
//         print('[UserApi] PUT /me (multipart) with token: $idToken, imagePath: $imagePath');
        
//         response = await _dio.put(
//           "/me",
//           data: formData,
//           options: Options(
//             headers: {
//               "Authorization": "Bearer $idToken",
//               "Content-Type": "multipart/form-data",
//             },
//           ),
//         );
//       } else {
//         print('[UserApi] PUT /me with token: $idToken, data: $cleanData');
        
//         response = await _dio.put(
//           "/me",
//           data: cleanData,
//           options: Options(
//             headers: {
//               "Authorization": "Bearer $idToken",
//               "Content-Type": "application/json",
//             },
//           ),
//         );
//       }
      
//       print('[UserApi] Raw response from PUT /me: ${response.data}');
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from PUT /me: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] updateMyUserInfo DioException: ${e.message}');
//       print('[UserApi][ERROR] Response data: ${e.response?.data}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to update user info';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] updateMyUserInfo: $e');
//       rethrow;
//     }
//   }

//   // Helper method to clean and validate payload data
//   static Map<String, dynamic> _cleanPayloadData(Map<String, dynamic> data) {
//     final cleanData = <String, dynamic>{};
    
//     for (final entry in data.entries) {
//       final key = entry.key;
//       final value = entry.value;
      
//       // Skip null or empty string values
//       if (value == null || (value is String && value.trim().isEmpty)) {
//         continue;
//       }
      
//       // Handle nested objects
//       if (value is Map) {
//         final nestedClean = _cleanPayloadData(Map<String, dynamic>.from(value));
//         if (nestedClean.isNotEmpty) {
//           cleanData[key] = nestedClean;
//         }
//       } 
//       // Handle arrays
//       else if (value is List) {
//         final cleanList = value.where((item) => 
//           item != null && 
//           (item is! String || item.trim().isNotEmpty)
//         ).toList();
//         if (cleanList.isNotEmpty) {
//           cleanData[key] = cleanList;
//         }
//       } 
//       // Handle primitive values
//       else {
//         cleanData[key] = value;
//       }
//     }
    
//     return cleanData;
//   }

//   // Delete user info
//   static Future<void> deleteMyUserInfo() async {
//     try {
//       final idToken = await _getToken();
//       print('[UserApi] DELETE /me with token: $idToken');
      
//       await _dio.delete(
//         "/me",
//         options: Options(headers: {"Authorization": "Bearer $idToken"}),
//       );
      
//       print('[UserApi] User info deleted successfully');
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] deleteMyUserInfo DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to delete user info';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] deleteMyUserInfo: $e');
//       rethrow;
//     }
//   }

//   // Regenerate invite code
//   static Future<Map<String, dynamic>> regenerateInviteCode() async {
//     try {
//       final idToken = await _getToken();
//       print('[UserApi] POST /me/regenerate-invite with token: $idToken');
      
//       final response = await _dio.post(
//         "/me/regenerate-invite",
//         options: Options(headers: {"Authorization": "Bearer $idToken"}),
//       );
      
//       print('[UserApi] Raw response from /me/regenerate-invite: ${response.data}');
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from /me/regenerate-invite: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] regenerateInviteCode DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to regenerate invite code';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] regenerateInviteCode: $e');
//       rethrow;
//     }
//   }

//   // Upload profile picture only
//   static Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
//     try {
//       final idToken = await _getToken();
//       final formData = FormData.fromMap({
//         'profilePicture': await MultipartFile.fromFile(
//           imagePath, 
//           filename: 'profile.jpg'
//         ),
//       });
      
//       print('[UserApi] POST /me/upload-picture with token: $idToken, imagePath: $imagePath');
      
//       final response = await _dio.post(
//         "/me/upload-picture",
//         data: formData,
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $idToken",
//             "Content-Type": "multipart/form-data",
//           },
//         ),
//       );
      
//       print('[UserApi] Raw response from /me/upload-picture: ${response.data}');
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from /me/upload-picture: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] uploadProfilePicture DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to upload profile picture';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] uploadProfilePicture: $e');
//       rethrow;
//     }
//   }

//   // Admin/utility: get all user infos
//   static Future<List<Map<String, dynamic>>> getAllUserInfos() async {
//     try {
//       final idToken = await _getToken();
//       print('[UserApi] GET / (all users) with token: $idToken');
      
//       final response = await _dio.get(
//         "/",
//         options: Options(headers: {"Authorization": "Bearer $idToken"}),
//       );
      
//       print('[UserApi] Raw response from GET /: ${response.data}');
//       final safeData = _safeListResponseCast(response.data);
//       print('[UserApi] Processed response from GET /: ${safeData.length} items');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] getAllUserInfos DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to get all user infos';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] getAllUserInfos: $e');
//       rethrow;
//     }
//   }

//   // Admin/utility: get user info by id
//   static Future<Map<String, dynamic>> getUserInfoById(String id) async {
//     try {
//       final idToken = await _getToken();
//       print('[UserApi] GET /$id with token: $idToken');
      
//       final response = await _dio.get(
//         "/$id",
//         options: Options(headers: {"Authorization": "Bearer $idToken"}),
//       );
      
//       print('[UserApi] Raw response from GET /$id: ${response.data}');
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from GET /$id: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] getUserInfoById DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to get user info by ID';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] getUserInfoById: $e');
//       rethrow;
//     }
//   }

//   // Admin: revoke referral code for a user
//   static Future<Map<String, dynamic>> revokeUserReferralCode(String id) async {
//     try {
//       final idToken = await _getToken();
//       print('[UserApi] POST /$id/revoke-referral with token: $idToken');
      
//       final response = await _dio.post(
//         "/$id/revoke-referral",
//         options: Options(headers: {"Authorization": "Bearer $idToken"}),
//       );
      
//       print('[UserApi] Raw response from /$id/revoke-referral: ${response.data}');
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from /$id/revoke-referral: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] revokeUserReferralCode DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to revoke referral code';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] revokeUserReferralCode: $e');
//       rethrow;
//     }
//   }

//   // Admin: update invite permissions for a user
//   static Future<Map<String, dynamic>> updateInvitePermissions(
//       String id, Map<String, dynamic> invitePermissions) async {
//     try {
//       final idToken = await _getToken();
//       final payload = {"invitePermissions": invitePermissions};
      
//       print('[UserApi] PATCH /$id/invite-permissions with token: $idToken');
//       print('[UserApi] Payload: $payload');
      
//       final response = await _dio.patch(
//         "/$id/invite-permissions",
//         data: payload,
//         options: Options(
//           headers: {
//             "Authorization": "Bearer $idToken",
//             "Content-Type": "application/json",
//           },
//         ),
//       );
      
//       print('[UserApi] Raw response from /$id/invite-permissions: ${response.data}');
//       final safeData = _safeResponseCast(response.data);
//       print('[UserApi] Processed response from /$id/invite-permissions: $safeData');
      
//       return safeData;
//     } on DioException catch (e) {
//       print('[UserApi][ERROR] updateInvitePermissions DioException: ${e.message}');
      
//       final errorMsg = e.response?.data?['message'] ?? 
//                       e.response?.data?['error'] ?? 
//                       e.message ?? 
//                       'Failed to update invite permissions';
//       throw Exception(errorMsg);
//     } catch (e) {
//       print('[UserApi][ERROR] updateInvitePermissions: $e');
//       rethrow;
//     }
//   }
// }