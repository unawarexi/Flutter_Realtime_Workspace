import 'package:flutter_realtime_workspace/core/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

class NotificationState {
  final RemoteMessage? lastMessage;
  final String? deviceToken;
  final bool isInitialized;

  NotificationState({
    this.lastMessage,
    this.deviceToken,
    this.isInitialized = false,
  });

  NotificationState copyWith({
    RemoteMessage? lastMessage,
    String? deviceToken,
    bool? isInitialized,
  }) {
    return NotificationState(
      lastMessage: lastMessage ?? this.lastMessage,
      deviceToken: deviceToken ?? this.deviceToken,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState());
  final NotificationService _service = NotificationService();

  Future<void> initialize() async {
    await _service.init(
      onForegroundMessage: (msg) {
        state = state.copyWith(lastMessage: msg);
      },
      onMessageOpenedApp: (msg) {
        state = state.copyWith(lastMessage: msg);
      },
    );
    state = state.copyWith(
      deviceToken: _service.deviceToken,
      isInitialized: true,
    );
  }

  Future<Response> sendNotification(Map<String, dynamic> data) {
    return _service.sendNotification(data);
  }

  Future<Response> sendMultipleNotifications(Map<String, dynamic> data) {
    return _service.sendMultipleNotifications(data);
  }

  Future<Response> sendTopicNotification(Map<String, dynamic> data) {
    return _service.sendTopicNotification(data);
  }

  Future<Response> subscribeDevicesToTopic(Map<String, dynamic> data) {
    return _service.subscribeDevicesToTopic(data);
  }

  Future<Response> unsubscribeDevicesFromTopic(Map<String, dynamic> data) {
    return _service.unsubscribeDevicesFromTopic(data);
  }

  Future<Response> validateToken(Map<String, dynamic> data) {
    return _service.validateToken(data);
  }

  Future<Response> getNotificationTypes() {
    return _service.getNotificationTypes();
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>(
  (ref) => NotificationNotifier(),
);
