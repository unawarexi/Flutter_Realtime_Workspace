// referalCode.js - Improved version with fixes

import crypto from 'crypto';
import UserInfo from '../models/userInfoModel.js';

// Generate a referral code with format: WRK + 6 random alphanum + TST
export function generateReferralCode() {
  const random = crypto.randomBytes(3).toString('hex').toUpperCase(); // 6 chars
  return `WRK${random}TST`;
}

// Set expiry for 7 days from now
export function getExpiryDate() {
  const expiry = new Date();
  expiry.setDate(expiry.getDate() + 7);
  return expiry;
}

// Assign referral code to user (admin/manager/employee/member) if allowed by invitePermissions
export async function assignReferralCode(user, options = {}) {
  // options.ignorePermissions: if true, skip invitePermissions check
  const role = user.permissionsLevel;

  if (!options.ignorePermissions) {
    // Check if user has permission to generate invite codes
    if (user.invitePermissions && user.invitePermissions[role] === false) {
      throw new Error('You do not have permission to generate invite codes.');
    }
  }

  // Generate new code even if user already has one (for regeneration)
  const code = generateReferralCode();
  user.inviteCode = code;
  user.inviteCodeExpiry = getExpiryDate();
  await user.save();
  return code;
}

// Validate a referral code (check existence and expiry)
export async function validateReferralCode(code) {
  const user = await UserInfo.findOne({ inviteCode: code });
  if (!user) return { valid: false, reason: 'Code not found' };

  if (user.inviteCodeExpiry && user.inviteCodeExpiry < new Date()) {
    // Code expired - regenerate automatically
    try {
      await assignReferralCode(user);
      return {
        valid: false,
        reason: 'Code expired, regenerated',
        regenerated: user.inviteCode
      };
    } catch (error) {
      return {
        valid: false,
        reason: 'Code expired and regeneration failed',
        error: error.message
      };
    }
  }

  return { valid: true, owner: user };
}

// Use a referral code (when new user joins with code)
export async function useReferralCode({ memberUser, code }) {
  console.log(`[useReferralCode] Member ${memberUser.email} using code: ${code}`);

  const validation = await validateReferralCode(code);
  if (!validation.valid) {
    console.log(`[useReferralCode] Invalid code: ${validation.reason}`);
    return {
      success: false,
      reason: validation.regenerated ? 'Code expired, regenerated' : 'Invalid code',
      regenerated: validation.regenerated
    };
  }

  const owner = validation.owner;
  console.log(`[useReferralCode] Valid code owner: ${owner.email}`);

  // Initialize arrays if they don't exist
  if (!Array.isArray(memberUser.invitedBy)) memberUser.invitedBy = [];
  if (!Array.isArray(owner.referredTo)) owner.referredTo = [];

  // Update memberUser's invitedBy array (prevent duplicates)
  const alreadyInvitedBy = memberUser.invitedBy.some((inviter) => inviter.inviterCode === code);

  if (!alreadyInvitedBy) {
    memberUser.invitedBy.push({
      email: owner.email,
      name: owner.fullName || owner.displayName || owner.email,
      inviterCode: code
    });
    console.log(`[useReferralCode] Added ${owner.email} to ${memberUser.email}'s invitedBy`);
  }

  // Update owner's referredTo array (prevent duplicates)
  const alreadyReferred = owner.referredTo.some((referred) => referred.email === memberUser.email);

  if (!alreadyReferred) {
    owner.referredTo.push({
      email: memberUser.email,
      name: memberUser.fullName || memberUser.displayName || memberUser.email
    });
    console.log(`[useReferralCode] Added ${memberUser.email} to ${owner.email}'s referredTo`);
  }

  // Inherit company name from owner if member doesn't have one
  if (owner.companyName && !memberUser.companyName) {
    memberUser.companyName = owner.companyName;
    console.log(`[useReferralCode] Set company name: ${owner.companyName}`);
  }

  // Generate new referral code for the new member
  try {
    const newCode = await assignReferralCode(memberUser);
    console.log(`[useReferralCode] Generated new code for ${memberUser.email}: ${newCode}`);
  } catch (error) {
    console.error(`[useReferralCode] Failed to generate code for new member:`, error.message);
    // Continue without failing the entire process
  }

  // Save both users
  await Promise.all([memberUser.save(), owner.save()]);

  console.log(`[useReferralCode] Successfully processed referral for ${memberUser.email}`);
  return { success: true, owner, newMemberCode: memberUser.inviteCode };
}

// Revoke a referral code (admin only)
export async function revokeReferralCode(user) {
  console.log(`[revokeReferralCode] Revoking code for user: ${user.email}`);
  user.inviteCode = null;
  user.inviteCodeExpiry = null;
  await user.save();
}

// Check and auto-regenerate expired codes for all users (can be run as a cron job)
export async function autoRegenerateExpiredCodes() {
  console.log('[autoRegenerateExpiredCodes] Starting auto-regeneration...');
  const now = new Date();
  const users = await UserInfo.find({
    inviteCodeExpiry: { $lt: now },
    inviteCode: { $exists: true, $ne: null }
  });

  console.log(`[autoRegenerateExpiredCodes] Found ${users.length} expired codes`);

  for (const user of users) {
    try {
      await assignReferralCode(user);
      console.log(`[autoRegenerateExpiredCodes] Regenerated code for ${user.email}`);
    } catch (error) {
      console.error(`[autoRegenerateExpiredCodes] Failed to regenerate for ${user.email}:`, error.message);
    }
  }

  console.log('[autoRegenerateExpiredCodes] Auto-regeneration completed');
}

// Get referral statistics for a user
export async function getReferralStats(userId) {
  const user = await UserInfo.findById(userId);
  if (!user) return null;

  const stats = {
    userEmail: user.email,
    inviteCode: user.inviteCode,
    inviteCodeExpiry: user.inviteCodeExpiry,
    directReferrals: user.referredTo ? user.referredTo.length : 0,
    invitedBy: user.invitedBy || [],
    referredTo: user.referredTo || []
  };

  // Calculate total referrals in the chain (recursive)
  const calculateTotalReferrals = async (userEmail, visited = new Set()) => {
    if (visited.has(userEmail)) return 0; // Prevent circular references
    visited.add(userEmail);

    const currentUser = await UserInfo.findOne({ email: userEmail });
    if (!currentUser || !currentUser.referredTo) return 0;

    let total = currentUser.referredTo.length;
    for (const referred of currentUser.referredTo) {
      total += await calculateTotalReferrals(referred.email, visited);
    }
    return total;
  };

  try {
    stats.totalReferralsInChain = await calculateTotalReferrals(user.email);
  } catch (error) {
    console.error('Error calculating total referrals:', error);
    stats.totalReferralsInChain = stats.directReferrals;
  }

  return stats;
}
