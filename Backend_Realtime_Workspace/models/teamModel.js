import mongoose from 'mongoose';

// Activity tracking schema for team activities
const activitySchema = new mongoose.Schema(
  {
    type: {
      type: String,
      enum: [
        'member_joined',
        'member_left',
        'member_role_changed',
        'member_invited',
        'project_created',
        'project_assigned',
        'project_completed',
        'project_archived',
        'team_created',
        'team_updated',
        'team_archived',
        'settings_changed',
      ],
      required: true,
    },
    actor: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' },
    target: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' }, // for member-related activities
    projectId: { type: mongoose.Schema.Types.ObjectId, ref: 'Project' }, // for project-related activities
    description: { type: String, required: true },
    metadata: { type: mongoose.Schema.Types.Mixed }, // additional data
    timestamp: { type: Date, default: Date.now },
  },
  { _id: false }
);

// Enhanced team member schema with permissions and activity tracking
const teamMemberSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'UserInfo',
      required: true,
    },
    role: {
      type: String,
      enum: ['owner', 'admin', 'manager', 'member', 'viewer', 'guest'],
      default: 'member',
    },
    permissions: {
      canCreateProjects: { type: Boolean, default: true },
      canDeleteProjects: { type: Boolean, default: false },
      canManageMembers: { type: Boolean, default: false },
      canInviteMembers: { type: Boolean, default: false },
      canChangeSettings: { type: Boolean, default: false },
      canViewAllProjects: { type: Boolean, default: true },
      canExportData: { type: Boolean, default: false },
      canManageIntegrations: { type: Boolean, default: false },
    },
    joinedAt: { type: Date, default: Date.now },
    invitedAt: { type: Date },
    invitedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' },
    status: {
      type: String,
      enum: ['active', 'invited', 'suspended', 'removed'],
      default: 'active',
    },
    lastActive: { type: Date, default: Date.now },
    favoriteProjects: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Project' }],
    notificationSettings: {
      email: { type: Boolean, default: true },
      push: { type: Boolean, default: true },
      projectUpdates: { type: Boolean, default: true },
      mentions: { type: Boolean, default: true },
      weeklyDigest: { type: Boolean, default: true },
    },
  },
  { _id: false }
);

// Enhanced invite schema with more tracking
const inviteSchema = new mongoose.Schema(
  {
    email: { type: String, required: true },
    role: {
      type: String,
      enum: ['admin', 'manager', 'member', 'viewer', 'guest'],
      default: 'member',
    },
    invitedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'UserInfo',
      required: true,
    },
    token: { type: String, required: true, unique: true },
    message: { type: String }, // custom invite message
    invitedAt: { type: Date, default: Date.now },
    expiresAt: { type: Date, required: true },
    acceptedAt: { type: Date },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'expired', 'cancelled', 'resent'],
      default: 'pending',
    },
    attempts: { type: Number, default: 0 }, // number of times invite was sent
    lastSentAt: { type: Date, default: Date.now },
  },
  { _id: true }
);

// Main team schema
const teamSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    slug: { type: String, unique: true, sparse: true },
    description: { type: String, trim: true },
    avatar: { type: String }, // team avatar URL

    // Team metadata
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'UserInfo',
      // required: true,
    },
    industry: { type: String },
    size: {
      type: String,
      enum: ['1-10', '11-50', '51-100', '101-500', '500+'],
    },
    type: {
      type: String,
      enum: ['company', 'agency', 'startup', 'non-profit', 'educational', 'personal'],
      default: 'company',
    },

    // Status and lifecycle
    status: {
      type: String,
      enum: ['active', 'archived', 'suspended'],
      default: 'active',
    },
    isActive: { type: Boolean, default: true },
    archived: { type: Boolean, default: false },
    archivedAt: { type: Date },
    archivedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' },

    // Members and invitations
    members: [teamMemberSchema],
    invites: [inviteSchema],
    memberLimit: { type: Number, default: 50 }, // subscription-based limit

    // Projects relationship
    projects: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Project' }],

    // Team settings
    settings: {
      isPublic: { type: Boolean, default: false },
      allowPublicProjects: { type: Boolean, default: false },
      requireApprovalForJoining: { type: Boolean, default: true },
      allowMemberInvites: { type: Boolean, default: true },
      defaultProjectTemplate: { type: String, default: 'Kanban' },
      timezone: { type: String, default: 'UTC' },
      workingDays: {
        type: [String],
        default: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
      },
      workingHours: {
        start: { type: String, default: '09:00' },
        end: { type: String, default: '17:00' },
      },
      notifications: {
        emailDigest: { type: Boolean, default: true },
        slackIntegration: { type: Boolean, default: false },
        projectDeadlines: { type: Boolean, default: true },
      },
    },

    // Subscription and billing (for future use)
    subscription: {
      plan: {
        type: String,
        enum: ['free', 'basic', 'pro', 'enterprise'],
        default: 'free',
      },
      status: {
        type: String,
        enum: ['active', 'cancelled', 'expired'],
        default: 'active',
      },
      expiresAt: { type: Date },
      features: { type: [String], default: [] },
    },

    // Activity and analytics
    activities: [activitySchema],
    stats: {
      totalProjects: { type: Number, default: 0 },
      activeProjects: { type: Number, default: 0 },
      completedProjects: { type: Number, default: 0 },
      totalMembers: { type: Number, default: 0 },
      activeMembers: { type: Number, default: 0 },
      lastActivityAt: { type: Date, default: Date.now },
    },

    // Custom fields for extensibility
    customFields: { type: mongoose.Schema.Types.Mixed },

    // Integration settings
    integrations: {
      slack: {
        enabled: { type: Boolean, default: false },
        webhookUrl: { type: String },
        channel: { type: String },
      },
      github: {
        enabled: { type: Boolean, default: false },
        organization: { type: String },
        repositories: [{ type: String }],
      },
      googleWorkspace: {
        enabled: { type: Boolean, default: false },
        domain: { type: String },
      },
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Indexes for performance
teamSchema.index({ createdBy: 1 });
teamSchema.index({ status: 1 });
teamSchema.index({ 'members.userId': 1 });
teamSchema.index({ 'invites.email': 1 });
teamSchema.index({ archived: 1, status: 1 });

// Virtual fields
teamSchema.virtual('memberCount').get(function () {
  return this.members ? this.members.filter((m) => m.status === 'active').length : 0;
});

teamSchema.virtual('pendingInviteCount').get(function () {
  return this.invites ? this.invites.filter((i) => i.status === 'pending').length : 0;
});

teamSchema.virtual('activeProjectCount').get(function () {
  return this.stats.activeProjects || 0;
});

teamSchema.virtual('isOwner').get(function () {
  // This would be set dynamically based on current user context
  return false;
});

// Pre-save middleware
teamSchema.pre('save', function (next) {
  // Generate slug from name if not provided
  if (!this.slug && this.name) {
    this.slug = this.name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  // Update member count
  this.stats.totalMembers = this.members.length;
  this.stats.activeMembers = this.members.filter((m) => m.status === 'active').length;

  // Update last activity
  this.stats.lastActivityAt = new Date();

  console.log('[teamModel] Pre-save: members =', this.members);
  next();
});

// Instance methods
teamSchema.methods.addMember = function (userId, role = 'member', invitedBy = null) {
  const existingMember = this.members.find((m) => m.userId.toString() === userId.toString());
  if (existingMember) {
    throw new Error('User is already a member of this team');
  }

  // Set default permissions based on role
  const permissions = this.getDefaultPermissions(role);

  this.members.push({
    userId,
    role,
    permissions,
    invitedBy,
    joinedAt: new Date(),
    status: 'active',
  });

  // Add activity
  this.addActivity('member_joined', invitedBy, userId, `New member joined the team`);

  return this.save();
};

teamSchema.methods.removeMember = function (userId, removedBy = null) {
  const memberIndex = this.members.findIndex((m) => m.userId.toString() === userId.toString());
  if (memberIndex === -1) {
    throw new Error('User is not a member of this team');
  }

  const member = this.members[memberIndex];
  if (member.role === 'owner') {
    throw new Error('Cannot remove team owner');
  }

  this.members.splice(memberIndex, 1);

  // Add activity
  this.addActivity('member_left', removedBy, userId, `Member was removed from the team`);

  return this.save();
};

teamSchema.methods.updateMemberRole = function (userId, newRole, updatedBy = null) {
  const member = this.members.find((m) => m.userId.toString() === userId.toString());
  if (!member) {
    throw new Error('User is not a member of this team');
  }

  const oldRole = member.role;
  member.role = newRole;
  member.permissions = this.getDefaultPermissions(newRole);

  // Add activity
  this.addActivity('member_role_changed', updatedBy, userId, `Member role changed from ${oldRole} to ${newRole}`);

  return this.save();
};

teamSchema.methods.inviteMember = function (email, role = 'member', invitedBy, message = '') {
  // Check if already invited
  const existingInvite = this.invites.find((i) => i.email === email && i.status === 'pending');
  if (existingInvite) {
    throw new Error('User already has a pending invitation');
  }

  // Generate unique token
  const token = require('crypto').randomBytes(32).toString('hex');
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 7); // 7 days expiry

  this.invites.push({
    email,
    role,
    invitedBy,
    token,
    message,
    expiresAt,
    status: 'pending',
  });

  // Add activity
  this.addActivity('member_invited', invitedBy, null, `Invitation sent to ${email}`);

  return this.save();
};

teamSchema.methods.acceptInvite = function (token, userId) {
  const invite = this.invites.find((i) => i.token === token && i.status === 'pending');
  if (!invite) {
    throw new Error('Invalid or expired invitation');
  }

  if (new Date() > invite.expiresAt) {
    invite.status = 'expired';
    throw new Error('Invitation has expired');
  }

  // Add user as member
  this.addMember(userId, invite.role, invite.invitedBy);

  // Update invite status
  invite.status = 'accepted';
  invite.acceptedAt = new Date();

  return this.save();
};

teamSchema.methods.addActivity = function (type, actor, target, description, metadata = {}) {
  this.activities.unshift({
    type,
    actor,
    target,
    description,
    metadata,
    timestamp: new Date(),
  });

  // Keep only last 100 activities
  if (this.activities.length > 100) {
    this.activities = this.activities.slice(0, 100);
  }
};

teamSchema.methods.getDefaultPermissions = function (role) {
  const permissionsByRole = {
    owner: {
      canCreateProjects: true,
      canDeleteProjects: true,
      canManageMembers: true,
      canInviteMembers: true,
      canChangeSettings: true,
      canViewAllProjects: true,
      canExportData: true,
      canManageIntegrations: true,
    },
    admin: {
      canCreateProjects: true,
      canDeleteProjects: true,
      canManageMembers: true,
      canInviteMembers: true,
      canChangeSettings: true,
      canViewAllProjects: true,
      canExportData: true,
      canManageIntegrations: false,
    },
    manager: {
      canCreateProjects: true,
      canDeleteProjects: false,
      canManageMembers: false,
      canInviteMembers: true,
      canChangeSettings: false,
      canViewAllProjects: true,
      canExportData: true,
      canManageIntegrations: false,
    },
    member: {
      canCreateProjects: true,
      canDeleteProjects: false,
      canManageMembers: false,
      canInviteMembers: false,
      canChangeSettings: false,
      canViewAllProjects: true,
      canExportData: false,
      canManageIntegrations: false,
    },
    viewer: {
      canCreateProjects: false,
      canDeleteProjects: false,
      canManageMembers: false,
      canInviteMembers: false,
      canChangeSettings: false,
      canViewAllProjects: true,
      canExportData: false,
      canManageIntegrations: false,
    },
    guest: {
      canCreateProjects: false,
      canDeleteProjects: false,
      canManageMembers: false,
      canInviteMembers: false,
      canChangeSettings: false,
      canViewAllProjects: false,
      canExportData: false,
      canManageIntegrations: false,
    },
  };

  return permissionsByRole[role] || permissionsByRole.member;
};

// Static methods
teamSchema.statics.findBySlug = function (slug) {
  return this.findOne({ slug, status: 'active' });
};

teamSchema.statics.findUserTeams = function (userId) {
  return this.find({
    'members.userId': userId,
    'members.status': 'active',
    status: 'active',
  }).populate('members.userId', 'fullName email profilePicture');
};

teamSchema.statics.getTeamStats = function (teamId) {
  return this.aggregate([
    { $match: { _id: new mongoose.Types.ObjectId(teamId) } },
    {
      $lookup: {
        from: 'projects',
        localField: '_id',
        foreignField: 'teamId',
        as: 'teamProjects',
      },
    },
    {
      $addFields: {
        projectCount: { $size: '$teamProjects' },
        activeProjectCount: {
          $size: {
            $filter: {
              input: '$teamProjects',
              cond: { $eq: ['$$this.status', 'active'] },
            },
          },
        },
        completedProjectCount: {
          $size: {
            $filter: {
              input: '$teamProjects',
              cond: { $eq: ['$$this.status', 'completed'] },
            },
          },
        },
      },
    },
  ]);
};

const Team = mongoose.model('Team', teamSchema);

export default Team;
