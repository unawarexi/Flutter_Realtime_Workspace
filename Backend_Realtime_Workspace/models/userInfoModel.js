import mongoose from 'mongoose';

const userInfoSchema = new mongoose.Schema(
  {
    // Basic Profile Information
    fullName: { type: String },
    displayName: { type: String },
    profilePicture: { type: String }, // store URL or path
    email: { type: String, unique: true },
    userID: { type: String, required: true }, // <-- Add this line for Firebase UID
    phoneNumber: { type: String },

    // Workspace Role & Preferences
    roleTitle: { type: String },
    department: { type: String },
    workType: {
      type: String,
      enum: ['Full-time', 'Part-time', 'Freelancer', 'Intern'],
    },
    timezone: { type: String },
    workingHours: {
      start: { type: String },
      end: { type: String },
    },

    // Company or Organization
    companyName: { type: String },
    companyWebsite: { type: String },
    industry: { type: String },
    teamSize: { type: String, enum: ['1-10', '11-50', '51-100', '100+'] },
    officeLocation: { type: String },

    // Collaboration Details
    inviteCode: { type: String },
    inviteCodeExpiry: { type: Date }, // add this line
    invitedBy: [
      {
        email: { type: String, required: true },
        name: { type: String },
        inviterCode: { type: String }, // the code used to join
      },
    ],
    referredTo: [
      {
        email: { type: String, required: true },
        name: { type: String },
      },
    ],
    teamProjectName: { type: String },
    permissionsLevel: {
      type: String,
      enum: ['admin', 'manager', 'employee', 'member'],
    }, // updated enum

    // Role-based invite permissions (admin can toggle)
    invitePermissions: {
      admin: { type: Boolean, default: true },
      manager: { type: Boolean, default: true },
      employee: { type: Boolean, default: false },
    },

    // Optional Onboarding Enhancements
    interestsSkills: [{ type: String }],
    bio: { type: String },
    socialLinks: {
      linkedIn: { type: String },
      github: { type: String },
    },
    profileCompletion: { type: Number, default: 0 },

    // Technical Metadata (Backend-Only Fields)
    deviceInfo: { type: mongoose.Schema.Types.Mixed },
    authProvider: {
      type: String,
      enum: ['Google', 'GitHub', 'Microsoft', 'Email'],
    },
    signupTimestamp: { type: Date, default: Date.now },
    ipAddress: { type: String },
    isVerified: { type: Boolean, default: false },
  },
  { timestamps: true }
);

const UserInfo = mongoose.model('UserInfo', userInfoSchema);

export default UserInfo;
