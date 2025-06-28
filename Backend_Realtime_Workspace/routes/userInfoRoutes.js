import express from "express";
import {
  getMyUserInfo,
  createOrUpdateMyUserInfo,
  updateMyUserInfo,
  deleteMyUserInfo,
  getAllUserInfos,
  getUserInfoById,
  uploadProfilePicture,
  revokeUserReferralCode,
  regenerateMyInviteCode,
  updateInvitePermissions
} from "../controllers/userInfoControllers.js";
import { firebaseAuthMiddleware } from "../middlewares/firebaseAuthMiddleware.js";
import { upload } from "../services/cloudinary.js";

const router = express.Router();

// Routes with image upload capability
router.get("/me", firebaseAuthMiddleware, getMyUserInfo);
router.post("/me", firebaseAuthMiddleware, upload.single('profilePicture'), createOrUpdateMyUserInfo);
router.put("/me", firebaseAuthMiddleware, upload.single('profilePicture'), updateMyUserInfo);
router.delete("/me", firebaseAuthMiddleware, deleteMyUserInfo);

// Regenerate invite code manually before expiration
router.post("/me/regenerate-invite", firebaseAuthMiddleware, regenerateMyInviteCode);

// Separate endpoint for profile picture upload only
router.post("/me/upload-picture", firebaseAuthMiddleware, upload.single('profilePicture'), uploadProfilePicture);

// Admin/utility routes (optional, restrict in production)
router.get("/", firebaseAuthMiddleware, getAllUserInfos);
router.get("/:id", firebaseAuthMiddleware, getUserInfoById);
router.post("/:id/revoke-referral", firebaseAuthMiddleware, revokeUserReferralCode);
router.patch("/:id/invite-permissions", firebaseAuthMiddleware, updateInvitePermissions); // new route

export default router;