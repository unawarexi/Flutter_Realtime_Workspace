import admin from "firebase-admin";
import serviceAccount from "../config/flutter-realtime-workspace-firebase-adminsdk-i8fiv-ee91027b1e.json" assert { type: "json" };

// Initialize Firebase Admin if not already initialized
// if (!admin.apps.length) {
//   admin.initializeApp();
// }
const adminverify = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const firebaseAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      console.log(
        "[firebaseAuthMiddleware] No token provided in Authorization header"
      );
      return res.status(401).json({ message: "No token provided" });
    }
    const idToken = authHeader.split("Bearer ")[1];
    console.log("[firebaseAuthMiddleware] Received Bearer token:", idToken);

    // Add extra debug for token verification
    try {
      const decodedToken = await adminverify.auth().verifyIdToken(idToken);
      req.user = { uid: decodedToken.uid, email: decodedToken.email };
      console.log("[firebaseAuthMiddleware] Decoded Firebase user:", req.user);
      next();
    } catch (verifyErr) {
      console.error(
        "[firebaseAuthMiddleware] Token verification failed:",
        verifyErr
      );
      return res
        .status(401)
        .json({
          message: "Invalid or expired token",
          error: verifyErr.message,
        });
    }
  } catch (err) {
    console.error("[firebaseAuthMiddleware] Middleware error:", err.message);
    return res
      .status(500)
      .json({ message: "Auth middleware error", error: err.message });
  }
};
