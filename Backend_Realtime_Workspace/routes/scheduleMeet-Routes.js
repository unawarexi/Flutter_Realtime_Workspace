import express from 'express';
import ScheduleMeetController from '../controllers/scheduleMeet.js';
import { firebaseAuthMiddleware } from '../middlewares/firebaseAuthMiddleware.js';

const router = express.Router();

// CREATE
router.post('/', firebaseAuthMiddleware, ScheduleMeetController.createMeeting);
router.post('/template', firebaseAuthMiddleware, ScheduleMeetController.createMeetingTemplate);
router.post('/from-template/:templateId', firebaseAuthMiddleware, ScheduleMeetController.createFromTemplate);

// READ
router.get('/', firebaseAuthMiddleware, ScheduleMeetController.getAllMeetings);
router.get('/:id', firebaseAuthMiddleware, ScheduleMeetController.getMeetingById);
router.get('/user/:userID', firebaseAuthMiddleware, ScheduleMeetController.getUserMeetings);
router.get('/user/:userID/today', firebaseAuthMiddleware, ScheduleMeetController.getTodaysMeetings);
router.get('/user/:userID/upcoming', firebaseAuthMiddleware, ScheduleMeetController.getUpcomingMeetings);
router.get('/user/:userID/invitations', firebaseAuthMiddleware, ScheduleMeetController.getUserInvitations);
router.get('/user/:userID/conflicts', firebaseAuthMiddleware, ScheduleMeetController.getUserConflicts);
router.get('/user/:userID/calendar', firebaseAuthMiddleware, ScheduleMeetController.getCalendarView);
router.get('/user/:userID/stats', firebaseAuthMiddleware, ScheduleMeetController.getUserMeetingStats);
router.get('/analytics/:companyName', firebaseAuthMiddleware, ScheduleMeetController.getMeetingAnalytics);
router.get('/templates', firebaseAuthMiddleware, ScheduleMeetController.getMeetingTemplates);
router.get('/search', firebaseAuthMiddleware, ScheduleMeetController.searchMeetings);
router.get('/export', firebaseAuthMiddleware, ScheduleMeetController.exportMeetingData);

// UPDATE
router.put('/:id', firebaseAuthMiddleware, ScheduleMeetController.updateMeeting);
router.patch('/:id/status', firebaseAuthMiddleware, ScheduleMeetController.updateMeetingStatus);
router.patch('/:id/postpone', firebaseAuthMiddleware, ScheduleMeetController.postponeMeeting);
router.patch('/:id/reminder', firebaseAuthMiddleware, ScheduleMeetController.updateReminderSettings);
router.patch('/:id/notes/:noteId', firebaseAuthMiddleware, ScheduleMeetController.updateMeetingNotes);
router.patch('/:id/convert-timezone', firebaseAuthMiddleware, ScheduleMeetController.convertMeetingTimezone);
router.patch('/:id/recurring', firebaseAuthMiddleware, ScheduleMeetController.updateRecurringSeries);
router.patch('/:id/cancel-recurring', firebaseAuthMiddleware, ScheduleMeetController.cancelRecurringSeries);
router.patch('/:id/followup/:actionId', firebaseAuthMiddleware, ScheduleMeetController.updateFollowUpStatus);

// PARTICIPANT MANAGEMENT
router.post('/:id/participants', firebaseAuthMiddleware, ScheduleMeetController.addParticipant);
router.delete('/:id/participants/:userID', firebaseAuthMiddleware, ScheduleMeetController.removeParticipant);
router.patch(
  '/:id/participants/:userID/status',
  firebaseAuthMiddleware,
  ScheduleMeetController.updateParticipantStatus
);
router.patch('/:id/participants/:userID/join', firebaseAuthMiddleware, ScheduleMeetController.recordParticipantJoin);
router.patch('/:id/participants/:userID/leave', firebaseAuthMiddleware, ScheduleMeetController.recordParticipantLeave);

// ATTACHMENTS
router.post('/:id/attachments', firebaseAuthMiddleware, ScheduleMeetController.addAttachment);
router.delete('/:id/attachments/:attachmentId', firebaseAuthMiddleware, ScheduleMeetController.removeAttachment);

// NOTES
router.post('/:id/notes', firebaseAuthMiddleware, ScheduleMeetController.addMeetingNotes);

// RECORDINGS
router.post('/:id/recordings', firebaseAuthMiddleware, ScheduleMeetController.addRecording);

// FOLLOW-UPS
router.post('/:id/followup', firebaseAuthMiddleware, ScheduleMeetController.addFollowUpAction);

// BULK
router.patch('/bulk-update', firebaseAuthMiddleware, ScheduleMeetController.bulkUpdateMeetings);
router.patch('/bulk-delete', firebaseAuthMiddleware, ScheduleMeetController.bulkDeleteMeetings);

// CONFLICTS
router.get('/:id/conflicts', firebaseAuthMiddleware, ScheduleMeetController.checkConflicts);

// AVAILABILITY
router.get('/availability', firebaseAuthMiddleware, ScheduleMeetController.checkParticipantAvailability);

// INVITATIONS
router.post('/:id/invitations', firebaseAuthMiddleware, ScheduleMeetController.sendInvitations);

// DELETE/RESTORE
router.delete('/:id', firebaseAuthMiddleware, ScheduleMeetController.deleteMeeting);
router.delete('/:id/permanent', firebaseAuthMiddleware, ScheduleMeetController.permanentlyDeleteMeeting);
router.patch('/:id/restore', firebaseAuthMiddleware, ScheduleMeetController.restoreMeeting);

export default router;
