import crypto from "crypto";
import UserInfo from "../models/userInfoModel.js";

// Generate a referral code with format: WRK + 6 random alphanum + TST
export function generateReferralCode() {
  const random = crypto.randomBytes(3).toString("hex").toUpperCase(); // 6 chars
  return `WRK${random}TST`;
}

// Set expiry for 7 days from now
export function getExpiryDate() {
  const expiry = new Date();
  expiry.setDate(expiry.getDate() + 7);
  return expiry;
}

// Assign referral code to user (admin/manager/employee/member) if allowed by invitePermissions
export async function assignReferralCode(user) {
  // Check invitePermissions for this user's role
  const role = user.permissionsLevel;
  if (user.invitePermissions && user.invitePermissions[role] === false) {
    throw new Error("You do not have permission to generate invite codes.");
  }
  const code = generateReferralCode();
  user.inviteCode = code;
  user.inviteCodeExpiry = getExpiryDate();
  await user.save();
  return code;
}

// Validate a referral code (check existence and expiry)
export async function validateReferralCode(code) {
  const user = await UserInfo.findOne({ inviteCode: code });
  if (!user) return { valid: false, reason: "Code not found" };
  if (user.inviteCodeExpiry && user.inviteCodeExpiry < new Date()) {
    // Expired, auto-regenerate
    await assignReferralCode(user);
    return {
      valid: false,
      reason: "Code expired, regenerated",
      regenerated: user.inviteCode,
    };
  }
  return { valid: true, owner: user };
}

// Use a referral code (member joins with code)
export async function useReferralCode({ memberUser, code }) {
  const { valid, owner, regenerated } = await validateReferralCode(code);
  if (!valid)
    return {
      success: false,
      reason: regenerated ? "Code expired, regenerated" : "Invalid code",
      regenerated,
    };

  // Set invitedBy to owner's email
  memberUser.invitedBy = owner.email;

  // Set companyName to owner's companyName if present
  if (owner.companyName) {
    memberUser.companyName = owner.companyName;
  }

  // Add member to owner's referredTo array if not already present
  if (!owner.referredTo.some((obj) => obj.email === memberUser.email)) {
    owner.referredTo.push({ email: memberUser.email });
    await owner.save();
  }

  // Assign a new code to the member
  await assignReferralCode(memberUser);
  await memberUser.save();

  return { success: true, owner };
}

// Revoke a referral code (admin only)
export async function revokeReferralCode(user) {
  user.inviteCode = null;
  user.inviteCodeExpiry = null;
  await user.save();
}

// Check and auto-regenerate expired codes for all users (can be run as a cron job)
export async function autoRegenerateExpiredCodes() {
  const now = new Date();
  const users = await UserInfo.find({ inviteCodeExpiry: { $lt: now } });
  for (const user of users) {
    await assignReferralCode(user);
  }
}
