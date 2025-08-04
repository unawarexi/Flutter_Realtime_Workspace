import mongoose from 'mongoose';

const scheduleMeetSchema = new mongoose.Schema(
  {
    // Basic Meeting Information
    meetingTitle: {
      type: String,
      required: true,
      trim: true,
      maxLength: 200
    },
    description: {
      type: String,
      maxLength: 1000
    },
    agenda: {
      type: String,
      maxLength: 2000
    },

    // Meeting Organizer (Admin/Manager who created the meeting)
    organizer: {
      userID: { type: String, required: true }, // Firebase UID from UserInfo
      name: { type: String, required: true },
      email: { type: String, required: true },
      profilePicture: { type: String },
      roleTitle: { type: String },
      department: { type: String }
    },

    // Date & Time Information
    meetingDate: {
      type: Date,
      required: true
    },
    meetingTime: {
      start: { type: String, required: true }, // Format: "14:30"
      end: { type: String, required: true } // Format: "15:30"
    },
    duration: {
      type: Number, // Duration in minutes (changed from String enum to Number)
      required: true,
      min: 5, // Minimum 5 minutes
      max: 480 // Maximum 8 hours
    },
    timezone: {
      type: String,
      default: 'UTC'
    },

    // Recurrence Settings
    repeatOption: {
      type: String,
      enum: ['None', 'Daily', 'Weekly', 'Bi-weekly', 'Monthly'],
      default: 'None'
    },
    recurrenceEndDate: { type: Date }, // When recurring meetings should stop
    recurringMeetings: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ScheduleMeet'
      }
    ], // For linking recurring meetings

    // Meeting Type & Location
    meetingType: {
      type: String,
      enum: ['Virtual', 'Physical'],
      required: true
    },
    location: {
      // For Physical meetings
      address: { type: String },
      mapLink: { type: String }, // Google Maps link
      coordinates: {
        latitude: { type: Number },
        longitude: { type: Number }
      },
      // For Virtual meetings
      meetingLink: { type: String },
      meetingPassword: { type: String },
      platform: {
        type: String,
        enum: ['Zoom', 'Google Meet', 'Microsoft Teams', 'Other']
      }
    },

    // Participants Management
    participants: [
      {
        userID: { type: String, required: true }, // Firebase UID
        name: { type: String, required: true },
        email: { type: String, required: true },
        profilePicture: { type: String },
        roleTitle: { type: String },
        department: { type: String },
        permissionsLevel: {
          type: String,
          enum: ['admin', 'manager', 'employee', 'member']
        },
        // Participation Status
        status: {
          type: String,
          enum: ['invited', 'accepted', 'declined', 'tentative', 'no-response'],
          default: 'invited'
        },
        responseDate: { type: Date },
        joinedAt: { type: Date }, // When they actually joined the meeting
        leftAt: { type: Date } // When they left the meeting
      }
    ],

    // Meeting Status & Lifecycle
    status: {
      type: String,
      enum: ['scheduled', 'ongoing', 'ended', 'cancelled', 'postponed'],
      default: 'scheduled'
    },
    actualStartTime: { type: Date }, // When meeting actually started
    actualEndTime: { type: Date }, // When meeting actually ended
    cancellationReason: { type: String },
    postponedTo: {
      date: { type: Date },
      time: {
        start: { type: String },
        end: { type: String }
      }
    },

    // Notification & Reminder Settings
    reminderSettings: {
      enabled: { type: Boolean, default: true },
      reminderTime: {
        type: String,
        enum: ['5 minutes before', '15 minutes before', '30 minutes before', '1 hour before', '2 hours before', '1 day before'],
        default: '15 minutes before'
      },
      notificationMethods: [
        {
          type: String,
          enum: ['push', 'email', 'sms']
        }
      ]
    },

    // Attachments & Resources
    attachments: [
      {
        fileName: { type: String, required: true },
        fileUrl: { type: String, required: true },
        fileSize: { type: Number }, // in bytes
        mimeType: { type: String },
        uploadedBy: {
          userID: { type: String, required: true },
          name: { type: String, required: true }
        },
        uploadedAt: { type: Date, default: Date.now },
        isPublic: { type: Boolean, default: true } // Can all participants download?
      }
    ],

    // Meeting Analytics & Metadata
    analytics: {
      invitesSent: { type: Number, default: 0 },
      acceptedCount: { type: Number, default: 0 },
      declinedCount: { type: Number, default: 0 },
      actualAttendees: { type: Number, default: 0 },
      averageJoinTime: { type: Number }, // minutes after start time
      meetingDuration: { type: Number }, // actual duration in minutes
      recordingUrl: { type: String }, // if meeting was recorded
      meetingNotes: { type: String } // post-meeting notes
    },

    // Access Control & Permissions
    visibility: {
      type: String,
      enum: ['public', 'private', 'department-only', 'team-only'],
      default: 'team-only'
    },
    allowGuestUsers: { type: Boolean, default: false },
    requireApproval: { type: Boolean, default: false }, // For joining meeting

    // Company/Team Context (from UserInfo model)
    companyName: { type: String },
    department: { type: String },
    teamProjectName: { type: String },

    // Conflict Detection & Calendar Integration
    conflictChecked: { type: Boolean, default: false },
    conflictingMeetings: [
      {
        meetingId: { type: mongoose.Schema.Types.ObjectId, ref: 'ScheduleMeet' },
        conflictType: {
          type: String,
          enum: ['time-overlap', 'participant-conflict', 'resource-conflict']
        }
      }
    ],

    // Integration Data
    externalCalendarIds: [
      {
        platform: {
          type: String,
          enum: ['google', 'outlook', 'apple', 'other']
        },
        calendarId: { type: String },
        eventId: { type: String }
      }
    ],

    // Technical Metadata
    createdBy: {
      userID: { type: String, required: true },
      name: { type: String, required: true },
      ipAddress: { type: String }
    },
    lastModifiedBy: {
      userID: { type: String },
      name: { type: String },
      modifiedAt: { type: Date }
    },

    // Soft Delete
    isDeleted: { type: Boolean, default: false },
    deletedAt: { type: Date },
    deletedBy: {
      userID: { type: String },
      name: { type: String }
    }
  },
  {
    timestamps: true,
    // Add indexes for better query performance
    indexes: [{ meetingDate: 1, status: 1 }, { 'organizer.userID': 1 }, { 'participants.userID': 1 }, { companyName: 1, department: 1 }, { status: 1, meetingDate: 1 }]
  }
);

// Indexes for optimized queries
scheduleMeetSchema.index({ meetingDate: 1, status: 1 });
scheduleMeetSchema.index({ 'organizer.userID': 1, status: 1 });
scheduleMeetSchema.index({ 'participants.userID': 1, meetingDate: 1 });
scheduleMeetSchema.index({ companyName: 1, department: 1, meetingDate: 1 });

// Virtual field for meeting duration (now just returns the duration field)
scheduleMeetSchema.virtual('durationInMinutes').get(function () {
  return this.duration;
});

// Virtual field to check if meeting is upcoming
scheduleMeetSchema.virtual('isUpcoming').get(function () {
  const now = new Date();
  return this.meetingDate > now && this.status === 'scheduled';
});

// Virtual field to check if meeting is today
scheduleMeetSchema.virtual('isToday').get(function () {
  const today = new Date();
  const meetingDay = new Date(this.meetingDate);
  return today.toDateString() === meetingDay.toDateString();
});

// Virtual field for formatted duration
scheduleMeetSchema.virtual('formattedDuration').get(function () {
  const duration = this.duration;
  if (duration < 60) {
    return `${duration} minutes`;
  } else if (duration % 60 === 0) {
    return `${duration / 60} hour${duration / 60 > 1 ? 's' : ''}`;
  } else {
    const hours = Math.floor(duration / 60);
    const minutes = duration % 60;
    return `${hours}h ${minutes}m`;
  }
});

// Pre-save middleware to update participant counts and calculate end time
scheduleMeetSchema.pre('save', function (next) {
  if (this.isModified('participants')) {
    this.analytics.acceptedCount = this.participants.filter((p) => p.status === 'accepted').length;
    this.analytics.declinedCount = this.participants.filter((p) => p.status === 'declined').length;
    this.analytics.invitesSent = this.participants.length;
  }

  // Auto-calculate end time based on start time and duration
  if (this.isModified('meetingTime.start') || this.isModified('duration')) {
    const [startHours, startMinutes] = this.meetingTime.start.split(':').map(Number);
    const startTotalMinutes = startHours * 60 + startMinutes;
    const endTotalMinutes = startTotalMinutes + this.duration;

    const endHours = Math.floor(endTotalMinutes / 60) % 24;
    const endMinutes = endTotalMinutes % 60;

    this.meetingTime.end = `${String(endHours).padStart(2, '0')}:${String(endMinutes).padStart(2, '0')}`;
  }

  next();
});

// Method to add participant
scheduleMeetSchema.methods.addParticipant = function (userInfo, status = 'invited') {
  const existingParticipant = this.participants.find((p) => p.userID === userInfo.userID);

  if (!existingParticipant) {
    this.participants.push({
      userID: userInfo.userID,
      name: userInfo.fullName || userInfo.displayName,
      email: userInfo.email,
      profilePicture: userInfo.profilePicture,
      roleTitle: userInfo.roleTitle,
      department: userInfo.department,
      permissionsLevel: userInfo.permissionsLevel,
      status: status
    });
  }

  return this.save();
};

// Method to update participant status
scheduleMeetSchema.methods.updateParticipantStatus = function (userID, status) {
  const participant = this.participants.find((p) => p.userID === userID);
  if (participant) {
    participant.status = status;
    participant.responseDate = new Date();
  }
  return this.save();
};

// Method to check for conflicts
scheduleMeetSchema.methods.checkConflicts = async function () {
  const ScheduleMeet = mongoose.model('ScheduleMeet');

  // Find overlapping meetings for the same participants
  const conflicts = await ScheduleMeet.find({
    _id: { $ne: this._id },
    status: 'scheduled',
    meetingDate: {
      $gte: new Date(this.meetingDate.getTime() - this.duration * 60000),
      $lte: new Date(this.meetingDate.getTime() + this.duration * 60000)
    },
    'participants.userID': {
      $in: this.participants.map((p) => p.userID)
    }
  });

  this.conflictingMeetings = conflicts.map((meeting) => ({
    meetingId: meeting._id,
    conflictType: 'time-overlap'
  }));

  this.conflictChecked = true;
  return this.save();
};

// Static method to find user's meetings
scheduleMeetSchema.statics.findUserMeetings = function (userID, options = {}) {
  const { status = ['scheduled', 'ongoing'], startDate = new Date(), endDate, limit = 50 } = options;

  const query = {
    $or: [{ 'organizer.userID': userID }, { 'participants.userID': userID }],
    status: Array.isArray(status) ? { $in: status } : status,
    meetingDate: { $gte: startDate },
    isDeleted: { $ne: true }
  };

  if (endDate) {
    query.meetingDate.$lte = endDate;
  }

  return this.find(query).sort({ meetingDate: 1 }).limit(limit).populate('recurringMeetings', 'meetingTitle meetingDate status');
};

// Static method for analytics
scheduleMeetSchema.statics.getAnalytics = function (companyName, options = {}) {
  const {
    startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Last 30 days
    endDate = new Date(),
    department
  } = options;

  const matchQuery = {
    companyName,
    meetingDate: { $gte: startDate, $lte: endDate },
    isDeleted: { $ne: true }
  };

  if (department) {
    matchQuery.department = department;
  }

  return this.aggregate([
    { $match: matchQuery },
    {
      $group: {
        _id: null,
        totalMeetings: { $sum: 1 },
        scheduledMeetings: { $sum: { $cond: [{ $eq: ['$status', 'scheduled'] }, 1, 0] } },
        completedMeetings: { $sum: { $cond: [{ $eq: ['$status', 'ended'] }, 1, 0] } },
        cancelledMeetings: { $sum: { $cond: [{ $eq: ['$status', 'cancelled'] }, 1, 0] } },
        avgAttendees: { $avg: '$analytics.actualAttendees' },
        totalAttendees: { $sum: '$analytics.actualAttendees' },
        avgDuration: { $avg: '$duration' },
        totalDuration: { $sum: '$duration' }
      }
    }
  ]);
};

const ScheduleMeet = mongoose.model('ScheduleMeet', scheduleMeetSchema);

export default ScheduleMeet;
