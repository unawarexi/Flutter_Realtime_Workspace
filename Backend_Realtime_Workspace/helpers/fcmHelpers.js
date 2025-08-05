import { sendFCMToDevice, sendFCMToMultipleDevices, sendFCMToTopic, NOTIFICATION_TYPES } from '../services/fcmServices.js';

/**
 * Helper functions for easy FCM integration in other controllers
 * These functions can be imported and used anywhere in your app
 */

/**
 * Send 2FA code notification
 * @param {string} fcmToken - User's FCM token
 * @param {string} code - 2FA code
 */
export const send2FACode = async (fcmToken, code) => {
  return await sendFCMToDevice(fcmToken, NOTIFICATION_TYPES.TWO_FA, { code });
};

/**
 * Notify user about new task assignment
 * @param {string} fcmToken - User's FCM token
 * @param {Object} taskData - Task information
 */
export const notifyTaskAssigned = async (fcmToken, taskData) => {
  const { taskTitle, assignedBy, projectName, dueDate, priority } = taskData;

  return await sendFCMToDevice(
    fcmToken,
    NOTIFICATION_TYPES.TASK_ASSIGNED,
    {
      taskTitle,
      assignedBy,
      projectName,
      dueDate,
      priority,
      taskId: taskData.id
    },
    {
      clickAction: `OPEN_TASK_${taskData.id}`,
      priority: priority === 'high' ? 'high' : 'normal'
    }
  );
};

/**
 * Notify team about task completion
 * @param {Array} fcmTokens - Team members' FCM tokens
 * @param {Object} taskData - Task completion data
 */
export const notifyTaskCompleted = async (fcmTokens, taskData) => {
  const { taskTitle, completedBy, projectName } = taskData;

  return await sendFCMToMultipleDevices(
    fcmTokens,
    NOTIFICATION_TYPES.TASK_COMPLETED,
    {
      taskTitle,
      userName: completedBy,
      projectName,
      taskId: taskData.id
    },
    {
      clickAction: `OPEN_PROJECT_${taskData.projectId}`
    }
  );
};

/**
 * Send project invitation
 * @param {string} fcmToken - Invitee's FCM token
 * @param {Object} inviteData - Invitation data
 */
export const sendProjectInvite = async (fcmToken, inviteData) => {
  const { projectName, invitedBy, role, workspaceName } = inviteData;

  return await sendFCMToDevice(
    fcmToken,
    NOTIFICATION_TYPES.PROJECT_INVITE,
    {
      projectName,
      invitedBy,
      role,
      workspaceName,
      projectId: inviteData.projectId
    },
    {
      clickAction: `OPEN_PROJECT_INVITE_${inviteData.projectId}`,
      priority: 'high'
    }
  );
};

/**
 * Notify user about team mention
 * @param {string} fcmToken - Mentioned user's FCM token
 * @param {Object} mentionData - Mention data
 */
export const notifyTeamMention = async (fcmToken, mentionData) => {
  const { userName, context, message, channelName } = mentionData;

  return await sendFCMToDevice(
    fcmToken,
    NOTIFICATION_TYPES.TEAM_MENTION,
    {
      userName,
      context: channelName || context,
      message,
      channelId: mentionData.channelId,
      messageId: mentionData.messageId
    },
    {
      clickAction: `OPEN_CHANNEL_${mentionData.channelId}`,
      priority: 'high'
    }
  );
};

/**
 * Send new message notification
 * @param {string} fcmToken - Recipient's FCM token
 * @param {Object} messageData - Message data
 */
export const notifyNewMessage = async (fcmToken, messageData) => {
  const { senderName, preview, channelName, isDirectMessage } = messageData;

  return await sendFCMToDevice(
    fcmToken,
    NOTIFICATION_TYPES.MESSAGE_RECEIVED,
    {
      senderName,
      preview: preview.length > 50 ? preview.substring(0, 50) + '...' : preview,
      channelName,
      isDirectMessage,
      messageId: messageData.messageId,
      channelId: messageData.channelId
    },
    {
      clickAction: isDirectMessage ? `OPEN_DM_${messageData.channelId}` : `OPEN_CHANNEL_${messageData.channelId}`
    }
  );
};

/**
 * Send meeting reminder
 * @param {Array} fcmTokens - Participants' FCM tokens
 * @param {Object} meetingData - Meeting data
 */
export const sendMeetingReminder = async (fcmTokens, meetingData) => {
  const { meetingTitle, startTime, timeRemaining, meetingLink } = meetingData;

  return await sendFCMToMultipleDevices(
    fcmTokens,
    NOTIFICATION_TYPES.MEETING_REMINDER,
    {
      meetingTitle,
      startTime,
      timeRemaining,
      meetingLink,
      meetingId: meetingData.meetingId
    },
    {
      clickAction: `OPEN_MEETING_${meetingData.meetingId}`,
      priority: 'high'
    }
  );
};

/**
 * Send deadline approaching notification
 * @param {string} fcmToken - User's FCM token
 * @param {Object} deadlineData - Deadline data
 */
export const notifyDeadlineApproaching = async (fcmToken, deadlineData) => {
  const { taskTitle, timeRemaining, priority } = deadlineData;

  return await sendFCMToDevice(
    fcmToken,
    NOTIFICATION_TYPES.DEADLINE_APPROACHING,
    {
      taskTitle,
      timeRemaining,
      priority,
      taskId: deadlineData.taskId,
      dueDate: deadlineData.dueDate
    },
    {
      clickAction: `OPEN_TASK_${deadlineData.taskId}`,
      priority: 'high',
      color: priority === 'high' ? '#FF5722' : '#FF9800'
    }
  );
};

/**
 * Send overdue task notification
 * @param {string} fcmToken - User's FCM token
 * @param {Object} taskData - Overdue task data
 */
export const notifyTaskOverdue = async (fcmToken, taskData) => {
  const { taskTitle, overdueDays, priority } = taskData;

  return await sendFCMToDevice(
    fcmToken,
    NOTIFICATION_TYPES.TASK_OVERDUE,
    {
      taskTitle,
      overdueDays,
      priority,
      taskId: taskData.taskId
    },
    {
      clickAction: `OPEN_TASK_${taskData.taskId}`,
      priority: 'high',
      color: '#F44336'
    }
  );
};

/**
 * Broadcast workspace update
 * @param {string} workspaceId - Workspace ID for topic
 * @param {Object} updateData - Update data
 */
export const broadcastWorkspaceUpdate = async (workspaceId, updateData) => {
  const topic = `workspace_${workspaceId}`;
  const { message, updateType, adminName } = updateData;

  return await sendFCMToTopic(
    topic,
    NOTIFICATION_TYPES.WORKSPACE_UPDATE,
    {
      message,
      updateType,
      adminName,
      workspaceId
    },
    {
      clickAction: `OPEN_WORKSPACE_${workspaceId}`
    }
  );
};

/**
 * Bulk notification helper for user arrays
 * @param {Array} users - Array of user objects with fcmToken property
 * @param {string} type - Notification type
 * @param {Object} data - Notification data
 * @param {Object} options - Notification options
 */
export const notifyUsers = async (users, type, data, options = {}) => {
  const validTokens = users.filter((user) => user.fcmToken && user.fcmToken.trim()).map((user) => user.fcmToken);

  if (validTokens.length === 0) {
    return { success: false, error: 'No valid FCM tokens found' };
  }

  return await sendFCMToMultipleDevices(validTokens, type, data, options);
};

/**
 * Smart notification sender - automatically chooses between single, multiple, or topic
 * @param {Object} recipients - Recipients configuration
 * @param {string} type - Notification type
 * @param {Object} data - Notification data
 * @param {Object} options - Notification options
 */
export const sendSmartNotification = async (recipients, type, data, options = {}) => {
  // Single token
  if (typeof recipients === 'string') {
    return await sendFCMToDevice(recipients, type, data, options);
  }

  // Topic notification
  if (recipients.topic) {
    return await sendFCMToTopic(recipients.topic, type, data, options);
  }

  // Multiple tokens
  if (Array.isArray(recipients.tokens)) {
    return await sendFCMToMultipleDevices(recipients.tokens, type, data, options);
  }

  // User objects array
  if (Array.isArray(recipients.users)) {
    return await notifyUsers(recipients.users, type, data, options);
  }

  throw new Error('Invalid recipients configuration');
};

/**
 * Workspace-specific notification helpers
 */

/**
 * Notify all workspace members
 * @param {string} workspaceId - Workspace ID
 * @param {string} type - Notification type
 * @param {Object} data - Notification data
 * @param {Object} options - Notification options
 */
export const notifyWorkspace = async (workspaceId, type, data, options = {}) => {
  const topic = `workspace_${workspaceId}`;
  return await sendFCMToTopic(topic, type, { ...data, workspaceId }, options);
};

/**
 * Notify all project members
 * @param {string} projectId - Project ID
 * @param {string} type - Notification type
 * @param {Object} data - Notification data
 * @param {Object} options - Notification options
 */
export const notifyProject = async (projectId, type, data, options = {}) => {
  const topic = `project_${projectId}`;
  return await sendFCMToTopic(topic, type, { ...data, projectId }, options);
};

/**
 * Notify all team members
 * @param {string} teamId - Team ID
 * @param {string} type - Notification type
 * @param {Object} data - Notification data
 * @param {Object} options - Notification options
 */
export const notifyTeam = async (teamId, type, data, options = {}) => {
  const topic = `team_${teamId}`;
  return await sendFCMToTopic(topic, type, { ...data, teamId }, options);
};

/**
 * Advanced notification scheduling and batching helpers
 */

/**
 * Batch multiple notifications with rate limiting
 * @param {Array} notifications - Array of notification objects
 * @param {number} batchSize - Number of notifications per batch
 * @param {number} delayMs - Delay between batches in milliseconds
 */
export const sendBatchNotifications = async (notifications, batchSize = 100, delayMs = 1000) => {
  const results = [];

  for (let i = 0; i < notifications.length; i += batchSize) {
    const batch = notifications.slice(i, i + batchSize);
    const batchPromises = batch.map(async (notification) => {
      try {
        const { recipients, type, data, options } = notification;
        return await sendSmartNotification(recipients, type, data, options);
      } catch (error) {
        return { success: false, error: error.message };
      }
    });

    const batchResults = await Promise.all(batchPromises);
    results.push(...batchResults);

    // Add delay between batches to avoid rate limiting
    if (i + batchSize < notifications.length) {
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }

  return {
    success: true,
    totalSent: notifications.length,
    successCount: results.filter((r) => r.success).length,
    failureCount: results.filter((r) => !r.success).length,
    results
  };
};

/**
 * Priority notification queue
 * @param {Object} notification - Notification object
 * @param {string} priority - Priority level: 'high', 'normal', 'low'
 */
export const sendPriorityNotification = async (notification, priority = 'normal') => {
  const { recipients, type, data, options = {} } = notification;

  // Set priority-specific options
  const priorityOptions = {
    ...options,
    priority: priority === 'high' ? 'high' : 'normal',
    ...(priority === 'high' && {
      android: {
        ...options.android,
        priority: 'high',
        notification: {
          ...options.android?.notification,
          priority: 'high',
          visibility: 'public'
        }
      },
      apns: {
        ...options.apns,
        headers: {
          ...options.apns?.headers,
          'apns-priority': '10'
        }
      }
    })
  };

  return await sendSmartNotification(recipients, type, data, priorityOptions);
};

/**
 * Utility functions for topic management
 */

/**
 * Generate workspace topic name
 * @param {string} workspaceId - Workspace ID
 */
export const getWorkspaceTopic = (workspaceId) => `workspace_${workspaceId}`;

/**
 * Generate project topic name
 * @param {string} projectId - Project ID
 */
export const getProjectTopic = (projectId) => `project_${projectId}`;

/**
 * Generate team topic name
 * @param {string} teamId - Team ID
 */
export const getTeamTopic = (teamId) => `team_${teamId}`;

/**
 * Generate user-specific topic name
 * @param {string} userId - User ID
 */
export const getUserTopic = (userId) => `user_${userId}`;

/**
 * Error handling and retry logic
 */

/**
 * Send notification with retry logic
 * @param {Function} notificationFn - Notification function to retry
 * @param {number} maxRetries - Maximum number of retries
 * @param {number} delayMs - Delay between retries
 */
export const sendWithRetry = async (notificationFn, maxRetries = 3, delayMs = 1000) => {
  let lastError;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const result = await notificationFn();
      if (result.success) {
        return result;
      }
      lastError = result.error;
    } catch (error) {
      lastError = error.message;
    }

    if (attempt < maxRetries) {
      await new Promise((resolve) => setTimeout(resolve, delayMs * attempt));
    }
  }

  return {
    success: false,
    error: `Failed after ${maxRetries} attempts. Last error: ${lastError}`,
    attempts: maxRetries
  };
};
