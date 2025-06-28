import UserInfo from "../models/userInfoModel.js";
import {
  uploadToCloudinary,
  deleteFromCloudinary,
} from "../services/cloudinary.js";
import { calculateProfileCompletion } from "../utils/profileCompletion.js";
import {
  assignReferralCode,
  useReferralCode,
  revokeReferralCode,
  autoRegenerateExpiredCodes,
} from "../utils/referalCode.js";

// Utility to ensure a field is always an array of strings
function ensureStringArray(val) {
  if (!val) return [];
  if (Array.isArray(val)) return val.map(String);
  return [String(val)];
}

// Create or update (upsert) user info for authenticated user with image upload
export const createOrUpdateMyUserInfo = async (req, res) => {
  try {
    console.log("[createOrUpdateMyUserInfo] Called by:", req.user);
    const { email, uid } = req.user;
    const data = req.body;
    console.log("[createOrUpdateMyUserInfo] Incoming data:", data);

    // Ensure interestsSkills and referredTo are always arrays of strings
    data.interestsSkills = ensureStringArray(data.interestsSkills);
    data.referredTo = ensureStringArray(data.referredTo);

    // Handle image upload if file is provided
    if (req.file) {
      try {
        console.log(
          "[createOrUpdateMyUserInfo] Image file detected:",
          req.file.path
        );
        // Get existing user info to check for old profile picture
        const existingUser = await UserInfo.findOne({ email });
        // Upload new image to Cloudinary
        const uploadResult = await uploadToCloudinary(
          req.file.path,
          "/projects/workspace"
        );
        console.log(
          "[createOrUpdateMyUserInfo] Uploaded to Cloudinary:",
          uploadResult
        );

        // Add the Cloudinary URL to the data
        data.profilePicture = uploadResult.url;
        data.profilePicturePublicId = uploadResult.public_id;

        // Delete old image from Cloudinary if it exists
        if (existingUser && existingUser.profilePicturePublicId) {
          console.log(
            "[createOrUpdateMyUserInfo] Deleting old Cloudinary image:",
            existingUser.profilePicturePublicId
          );
          await deleteFromCloudinary(existingUser.profilePicturePublicId);
        }
      } catch (uploadError) {
        console.error(
          "[createOrUpdateMyUserInfo] Failed to upload image:",
          uploadError.message
        );
        return res.status(500).json({
          message: "Failed to upload image",
          error: uploadError.message,
        });
      }
    }

    // Always set userID (Firebase UID) and email from token
    data.userID = uid;
    data.email = email;

    // Upsert: update if exists, else create
    let userInfo = await UserInfo.findOneAndUpdate(
      { email }, // You may also use { userID: uid } for stricter matching
      { ...data, email, userID: uid }, // always set email and userID from token
      { new: true, upsert: true, setDefaultsOnInsert: true }
    );
    console.log("[createOrUpdateMyUserInfo] Upserted userInfo:", userInfo);

    // Referral logic
    if (
      ["admin", "manager", "employee", "member"].includes(
        data.permissionsLevel
      ) &&
      !userInfo.inviteCode
    ) {
      try {
        console.log("[createOrUpdateMyUserInfo] Assigning referral code...");
        await assignReferralCode(userInfo);
      } catch (err) {
        console.error(
          "[createOrUpdateMyUserInfo] Referral code assignment failed:",
          err.message
        );
        // Return 400 instead of 403 for business logic error
        return res.status(400).json({
          message: "Referral code assignment failed",
          error: err.message,
        });
      }
    }
    // If member is using a referral code
    if (data.inviteCode && data.permissionsLevel === "member") {
      console.log(
        "[createOrUpdateMyUserInfo] Using referral code:",
        data.inviteCode
      );
      const result = await useReferralCode({
        memberUser: userInfo,
        code: data.inviteCode,
      });
      if (!result.success) {
        console.warn(
          "[createOrUpdateMyUserInfo] Invalid or expired referral code:",
          data.inviteCode
        );
        // Return 400 instead of 403 for business logic error
        return res.status(400).json({
          message: "Invalid or expired referral code",
          regenerated: result.regenerated,
        });
      }
    }

    // Recalculate profile completion
    userInfo.profileCompletion = calculateProfileCompletion(userInfo);
    await userInfo.save();
    console.log("[createOrUpdateMyUserInfo] Final userInfo:", userInfo);
    res.status(200).json(userInfo);
  } catch (err) {
    console.error(
      "[createOrUpdateMyUserInfo] Failed to save user info:",
      err.message
    );
    res
      .status(500)
      .json({ message: "Failed to save user info", error: err.message });
  }
};

// Update user info for authenticated user with image upload
export const updateMyUserInfo = async (req, res) => {
  try {
    console.log("[updateMyUserInfo] Called by:", req.user);
    const { email, uid } = req.user;
    const data = req.body;
    console.log("[updateMyUserInfo] Incoming data:", data);

    // Ensure interestsSkills and referredTo are always arrays of strings
    data.interestsSkills = ensureStringArray(data.interestsSkills);
    data.referredTo = ensureStringArray(data.referredTo);

    // Handle image upload if file is provided
    if (req.file) {
      try {
        console.log("[updateMyUserInfo] Image file detected:", req.file.path);
        // Get existing user info to check for old profile picture
        const existingUser = await UserInfo.findOne({ email });
        // Upload new image to Cloudinary
        const uploadResult = await uploadToCloudinary(
          req.file.path,
          "/projects/banking/profile-pictures"
        );
        console.log("[updateMyUserInfo] Uploaded to Cloudinary:", uploadResult);

        // Add the Cloudinary URL to the data
        data.profilePicture = uploadResult.url;
        data.profilePicturePublicId = uploadResult.public_id;

        // Delete old image from Cloudinary if it exists
        if (existingUser && existingUser.profilePicturePublicId) {
          console.log(
            "[updateMyUserInfo] Deleting old Cloudinary image:",
            existingUser.profilePicturePublicId
          );
          await deleteFromCloudinary(existingUser.profilePicturePublicId);
        }
      } catch (uploadError) {
        console.error(
          "[updateMyUserInfo] Failed to upload image:",
          uploadError.message
        );
        return res.status(500).json({
          message: "Failed to upload image",
          error: uploadError.message,
        });
      }
    }

    // Always set userID (Firebase UID) and email from token
    data.userID = uid;
    data.email = email;

    let user = await UserInfo.findOneAndUpdate(
      { email }, // You may also use { userID: uid }
      { $set: { ...data, userID: uid, email } },
      { new: true }
    );
    if (!user) {
      console.warn("[updateMyUserInfo] User info not found for email:", email);
      return res.status(404).json({ message: "User info not found" });
    }

    // Referral logic
    if (
      ["admin", "manager", "employee", "member"].includes(
        data.permissionsLevel
      ) &&
      !user.inviteCode
    ) {
      try {
        console.log("[updateMyUserInfo] Assigning referral code...");
        await assignReferralCode(user);
      } catch (err) {
        console.error(
          "[updateMyUserInfo] Referral code assignment failed:",
          err.message
        );
        return res.status(400).json({
          message: "Referral code assignment failed",
          error: err.message,
        });
      }
    }
    if (data.inviteCode && data.permissionsLevel === "member") {
      console.log("[updateMyUserInfo] Using referral code:", data.inviteCode);
      const result = await useReferralCode({
        memberUser: user,
        code: data.inviteCode,
      });
      if (!result.success) {
        console.warn(
          "[updateMyUserInfo] Invalid or expired referral code:",
          data.inviteCode
        );
        return res.status(400).json({
          message: "Invalid or expired referral code",
          regenerated: result.regenerated,
        });
      }
    }

    // Recalculate profile completion
    user.profileCompletion = calculateProfileCompletion(user);
    await user.save();
    console.log("[updateMyUserInfo] Final user:", user);
    res.json(user);
  } catch (err) {
    console.error(
      "[updateMyUserInfo] Failed to update user info:",
      err.message
    );
    res
      .status(500)
      .json({ message: "Failed to update user info", error: err.message });
  }
};

// Admin endpoint to revoke a user's referral code
export const revokeUserReferralCode = async (req, res) => {
  try {
    console.log(
      "[revokeUserReferralCode] Called by:",
      req.user,
      "for userId:",
      req.params.id
    );
    const { id } = req.params;
    const user = await UserInfo.findById(id);
    if (!user) {
      console.warn("[revokeUserReferralCode] User not found:", id);
      return res.status(404).json({ message: "User not found" });
    }
    await revokeReferralCode(user);
    console.log("[revokeUserReferralCode] Referral code revoked for user:", id);
    res.json({ message: "Referral code revoked" });
  } catch (err) {
    console.error(
      "[revokeUserReferralCode] Failed to revoke referral code:",
      err.message
    );
    res
      .status(500)
      .json({ message: "Failed to revoke referral code", error: err.message });
  }
};

// Delete user info for authenticated user (also deletes Cloudinary image)
export const deleteMyUserInfo = async (req, res) => {
  try {
    console.log("[deleteMyUserInfo] Called by:", req.user);
    const { email, uid } = req.user;
    const user = await UserInfo.findOne({ email, userID: uid });

    if (!user) {
      console.warn("[deleteMyUserInfo] User info not found for email:", email);
      return res.status(404).json({ message: "User info not found" });
    }

    // Delete image from Cloudinary if it exists
    if (user.profilePicturePublicId) {
      try {
        console.log(
          "[deleteMyUserInfo] Deleting Cloudinary image:",
          user.profilePicturePublicId
        );
        await deleteFromCloudinary(user.profilePicturePublicId);
      } catch (cloudinaryError) {
        console.error(
          "[deleteMyUserInfo] Failed to delete image from Cloudinary:",
          cloudinaryError
        );
        // Continue with user deletion even if Cloudinary deletion fails
      }
    }

    // Delete user info from MongoDB
    await UserInfo.findOneAndDelete({ email, userID: uid });
    console.log("[deleteMyUserInfo] User info deleted for email:", email);

    res.json({ message: "User info deleted" });
  } catch (err) {
    console.error(
      "[deleteMyUserInfo] Failed to delete user info:",
      err.message
    );
    res
      .status(500)
      .json({ message: "Failed to delete user info", error: err.message });
  }
};

// Upload profile picture only (separate endpoint for image-only updates)
export const uploadProfilePicture = async (req, res) => {
  try {
    console.log("[uploadProfilePicture] Called by:", req.user);
    const { email, uid } = req.user;

    if (!req.file) {
      console.warn("[uploadProfilePicture] No file provided");
      return res.status(400).json({ message: "No file provided" });
    }

    // Get existing user info to check for old profile picture
    const existingUser = await UserInfo.findOne({ email, userID: uid });

    if (!existingUser) {
      console.warn(
        "[uploadProfilePicture] User info not found for email:",
        email
      );
      return res.status(404).json({ message: "User info not found" });
    }

    try {
      // Upload new image to Cloudinary
      const uploadResult = await uploadToCloudinary(
        req.file.path,
        "/projects/banking/profile-pictures"
      );
      console.log(
        "[uploadProfilePicture] Uploaded to Cloudinary:",
        uploadResult
      );

      // Delete old image from Cloudinary if it exists
      if (existingUser.profilePicturePublicId) {
        console.log(
          "[uploadProfilePicture] Deleting old Cloudinary image:",
          existingUser.profilePicturePublicId
        );
        await deleteFromCloudinary(existingUser.profilePicturePublicId);
      }

      // Update user with new image URL
      const updatedUser = await UserInfo.findOneAndUpdate(
        { email, userID: uid },
        {
          $set: {
            profilePicture: uploadResult.url,
            profilePicturePublicId: uploadResult.public_id,
          },
        },
        { new: true }
      );

      // Recalculate profile completion
      updatedUser.profileCompletion = calculateProfileCompletion(updatedUser);
      await updatedUser.save();
      console.log("[uploadProfilePicture] Updated user:", updatedUser);
      res.json({
        message: "Profile picture uploaded successfully",
        profilePicture: uploadResult.url,
        user: updatedUser,
      });
    } catch (uploadError) {
      console.error(
        "[uploadProfilePicture] Failed to upload image:",
        uploadError.message
      );
      return res.status(500).json({
        message: "Failed to upload image",
        error: uploadError.message,
      });
    }
  } catch (err) {
    console.error("[uploadProfilePicture] Server error:", err.message);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Get all user infos (admin only, for demonstration)
export const getAllUserInfos = async (req, res) => {
  try {
    console.log("[getAllUserInfos] Called by:", req.user);
    const users = await UserInfo.find();
    res.json(users);
  } catch (err) {
    console.error("[getAllUserInfos] Server error:", err.message);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Get user info for authenticated user
export const getMyUserInfo = async (req, res) => {
  try {
    console.log("[getMyUserInfo] Called by:", req.user);
    const { email, uid } = req.user;
    const user = await UserInfo.findOne({ email, userID: uid });
    if (!user) {
      console.warn("[getMyUserInfo] User info not found for email:", email);
      return res.status(404).json({ message: "User info not found" });
    }
    res.json(user);
  } catch (err) {
    console.error("[getMyUserInfo] Server error:", err.message);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Get user info by ID (admin or for sharing, optional)
export const getUserInfoById = async (req, res) => {
  try {
    console.log(
      "[getUserInfoById] Called by:",
      req.user,
      "for userId:",
      req.params.id
    );
    const { id } = req.params;
    const user = await UserInfo.findById(id);
    if (!user) {
      console.warn("[getUserInfoById] User info not found for id:", id);
      return res.status(404).json({ message: "User info not found" });
    }
    res.json(user);
  } catch (err) {
    console.error("[getUserInfoById] Server error:", err.message);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Allow any user to manually regenerate their invite code before expiration
export const regenerateMyInviteCode = async (req, res) => {
  try {
    console.log("[regenerateMyInviteCode] Called by:", req.user);
    const { email } = req.user;
    const user = await UserInfo.findOne({ email });
    if (!user) {
      console.warn("[regenerateMyInviteCode] User not found for email:", email);
      return res.status(404).json({ message: "User not found" });
    }
    try {
      await assignReferralCode(user);
      console.log(
        "[regenerateMyInviteCode] Invite code regenerated:",
        user.inviteCode
      );
    } catch (err) {
      console.error(
        "[regenerateMyInviteCode] Failed to assign referral code:",
        err.message
      );
      // Return 400 instead of 403 for business logic error
      return res.status(400).json({ message: err.message });
    }
    res.json({
      message: "Invite code regenerated",
      inviteCode: user.inviteCode,
      inviteCodeExpiry: user.inviteCodeExpiry,
    });
  } catch (err) {
    console.error(
      "[regenerateMyInviteCode] Failed to regenerate invite code:",
      err.message
    );
    res.status(500).json({
      message: "Failed to regenerate invite code",
      error: err.message,
    });
  }
};

// Admin: Update invitePermissions for a user
export const updateInvitePermissions = async (req, res) => {
  try {
    console.log(
      "[updateInvitePermissions] Called by:",
      req.user,
      "for userId:",
      req.params.id,
      "with body:",
      req.body
    );
    const { id } = req.params;
    const { invitePermissions } = req.body;
    // Optionally: check if req.user is admin here
    const user = await UserInfo.findById(id);
    if (!user) {
      console.warn("[updateInvitePermissions] User not found for id:", id);
      return res.status(404).json({ message: "User not found" });
    }
    user.invitePermissions = {
      ...user.invitePermissions,
      ...invitePermissions,
    };
    await user.save();
    console.log(
      "[updateInvitePermissions] Updated invitePermissions:",
      user.invitePermissions
    );
    res.json({
      message: "Invite permissions updated",
      invitePermissions: user.invitePermissions,
    });
  } catch (err) {
    console.error(
      "[updateInvitePermissions] Failed to update invite permissions:",
      err.message
    );
    res.status(500).json({
      message: "Failed to update invite permissions",
      error: err.message,
    });
  }
};
