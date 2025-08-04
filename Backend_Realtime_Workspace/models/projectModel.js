import mongoose from 'mongoose';

const timelineEventSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String },
    date: { type: Date, default: Date.now },
    type: { type: String, default: 'custom' } // e.g. "created", "updated", "milestone", "attachment", "collaborators"
  },
  { _id: false }
);

const attachmentSchema = new mongoose.Schema(
  {
    url: { type: String, required: true },
    public_id: { type: String, required: true },
    resource_type: { type: String, required: true }, // "image", "video", "raw"
    format: { type: String }, // file extension
    bytes: { type: Number }, // file size in bytes
    filename: { type: String, required: true },
    original_filename: { type: String },
    type: { type: String }, // "image", "video", "audio", "document", etc.
    width: { type: Number }, // for images/videos
    height: { type: Number }, // for images/videos
    duration: { type: Number }, // for videos/audio (in seconds)
    uploadedAt: { type: Date, default: Date.now },
    uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' }
  },
  { _id: true } // Keep _id for attachments to enable individual deletion
);

const projectSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    key: { type: String, unique: true, sparse: true }, // e.g., PROJ-001
    description: { type: String, trim: true },
    template: {
      type: String,
      enum: ['Kanban', 'Scrum', 'Blank Project', 'Project Management', 'Task Tracking'],
      default: 'Kanban'
    },
    status: {
      type: String,
      enum: ['active', 'archived', 'on-hold', 'completed', 'planning', 'review', 'cancelled'],
      default: 'active'
    },
    isActive: { type: Boolean, default: true }, // quick status check
    archived: { type: Boolean, default: false },
    completed: { type: Boolean, default: false },
    recent: { type: Boolean, default: false },
    starred: { type: Boolean, default: false },
    priority: {
      type: String,
      enum: ['low', 'medium', 'high', 'critical'],
      default: 'medium'
    },
    color: { type: String, default: '#1E40AF' }, // hex color for UI
    teamId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Team'
      // required: true, // <-- Make optional
    },
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'UserInfo',
      required: true
    },
    collaborators: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'UserInfo'
      }
    ],
    members: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'UserInfo'
      }
    ],
    tags: [
      {
        type: String,
        trim: true,
        lowercase: true
      }
    ],
    startDate: { type: Date },
    endDate: { type: Date },
    lastViewed: { type: Date, default: Date.now },
    progress: {
      type: Number,
      min: 0,
      max: 1,
      default: 0
    }, // 0-1 (0% to 100%)

    // Enhanced attachments array with full metadata
    attachments: [attachmentSchema],

    // Project timeline for tracking all events
    timeline: [timelineEventSchema],

    // Budget and time tracking (optional)
    budget: {
      allocated: { type: Number, default: 0 },
      spent: { type: Number, default: 0 },
      currency: { type: String, default: 'USD' }
    },

    timeTracking: {
      estimated: { type: Number, default: 0 }, // in hours
      actual: { type: Number, default: 0 }, // in hours
      unit: { type: String, default: 'hours' }
    },

    // Custom fields for extensibility
    customFields: { type: mongoose.Schema.Types.Mixed },

    // Project settings
    settings: {
      isPublic: { type: Boolean, default: false },
      allowComments: { type: Boolean, default: true },
      notifications: { type: Boolean, default: true },
      autoArchive: { type: Boolean, default: false },
      autoArchiveDays: { type: Number, default: 90 }
    }
  },
  {
    timestamps: true,
    // Add indexes for better query performance
    toJSON: { virtuals: true },
    toObject: { virtuals: true }
  }
);

// Indexes for better performance
projectSchema.index({ teamId: 1, status: 1 });
projectSchema.index({ createdBy: 1 });
projectSchema.index({ starred: 1, teamId: 1 });
projectSchema.index({ archived: 1, teamId: 1 });
projectSchema.index({ lastViewed: -1 });
projectSchema.index({ tags: 1 });
projectSchema.index({ name: 'text', description: 'text' });

// Virtual fields
projectSchema.virtual('progressPercentage').get(function () {
  return Math.round(this.progress * 100);
});

projectSchema.virtual('attachmentCount').get(function () {
  return this.attachments ? this.attachments.length : 0;
});

projectSchema.virtual('collaboratorCount').get(function () {
  return this.collaborators ? this.collaborators.length : 0;
});

projectSchema.virtual('daysActive').get(function () {
  const now = new Date();
  const created = this.createdAt;
  const diffTime = Math.abs(now - created);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
});

projectSchema.virtual('isOverdue').get(function () {
  if (!this.endDate) return false;
  return new Date() > this.endDate && !this.completed;
});

// Pre-save middleware
projectSchema.pre('save', function (next) {
  // Update recent flag based on lastViewed
  const oneWeekAgo = new Date();
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
  this.recent = this.lastViewed && this.lastViewed > oneWeekAgo;

  // Auto-complete based on progress
  if (this.progress === 1 && !this.completed) {
    this.completed = true;
    this.status = 'completed';
  } else if (this.progress < 1 && this.completed) {
    this.completed = false;
    if (this.status === 'completed') {
      this.status = 'active';
    }
  }

  next();
});

// Instance methods
projectSchema.methods.addTimelineEvent = function (title, description, type = 'custom') {
  this.timeline.push({
    title,
    description,
    date: new Date(),
    type
  });
  return this.save();
};

projectSchema.methods.updateProgress = function (progress) {
  const oldProgress = this.progress;
  this.progress = progress;

  this.addTimelineEvent('Progress Updated', `Progress updated from ${Math.round(oldProgress * 100)}% to ${Math.round(progress * 100)}%`, 'progress');

  return this.save();
};

// Static methods
projectSchema.statics.getProjectStats = function (teamId = null) {
  const match = teamId ? { teamId: new mongoose.Types.ObjectId(teamId) } : {};

  return this.aggregate([
    { $match: match },
    {
      $group: {
        _id: null,
        total: { $sum: 1 },
        active: { $sum: { $cond: [{ $eq: ['$status', 'active'] }, 1, 0] } },
        completed: {
          $sum: { $cond: [{ $eq: ['$status', 'completed'] }, 1, 0] }
        },
        archived: { $sum: { $cond: ['$archived', 1, 0] } },
        starred: { $sum: { $cond: ['$starred', 1, 0] } },
        averageProgress: { $avg: '$progress' },
        totalAttachments: { $sum: { $size: '$attachments' } }
      }
    }
  ]);
};

projectSchema.statics.searchProjects = function (query, teamId = null) {
  const searchQuery = {
    $and: [
      teamId ? { teamId: new mongoose.Types.ObjectId(teamId) } : {},
      {
        $or: [{ name: { $regex: query, $options: 'i' } }, { description: { $regex: query, $options: 'i' } }, { key: { $regex: query, $options: 'i' } }, { tags: { $in: [new RegExp(query, 'i')] } }]
      }
    ]
  };

  return this.find(searchQuery);
};

const Project = mongoose.model('Project', projectSchema);

export default Project;
