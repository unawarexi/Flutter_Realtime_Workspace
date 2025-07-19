import admin from 'firebase-admin';
import serviceAccount from '../config/flutter-realtime-workspace-firebase-adminsdk-i8fiv-ee91027b1e.json' assert { type: 'json' };
import UserInfo from '../models/userInfoModel.js'; // Adjust path as needed

// Initialize Firebase Admin if not already initialized
const adminverify = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export const firebaseAuthMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('[firebaseAuthMiddleware] No token provided in Authorization header');
      return res.status(401).json({ message: 'No token provided' });
    }

    const idToken = authHeader.split('Bearer ')[1];
    console.log('[firebaseAuthMiddleware] Received Bearer token:', idToken);

    try {
      // Verify Firebase token
      const decodedToken = await adminverify.auth().verifyIdToken(idToken);
      const firebaseUID = decodedToken.uid;
      const email = decodedToken.email;

      console.log('[firebaseAuthMiddleware] Decoded Firebase user:', {
        uid: firebaseUID,
        email,
      });

      // Find or create user in MongoDB to ensure sync
      let userInfo = await UserInfo.findOne({ userID: firebaseUID });

      if (!userInfo) {
        // User doesn't exist in MongoDB, create minimal record
        console.log('[firebaseAuthMiddleware] Creating new user record for Firebase UID:', firebaseUID);

        userInfo = new UserInfo({
          userID: firebaseUID,
          email: email,
          authProvider: 'Google', // You might want to detect this from the token
          isVerified: decodedToken.email_verified || false,
          signupTimestamp: new Date(),
          // Add any other required fields with defaults
        });

        try {
          await userInfo.save();
          console.log('[firebaseAuthMiddleware] User created successfully:', userInfo._id);
        } catch (saveError) {
          console.error('[firebaseAuthMiddleware] Error creating user:', saveError);
          // Continue with authentication even if user creation fails
        }
      } else {
        // User exists, optionally update last seen or other fields
        console.log('[firebaseAuthMiddleware] Found existing user:', userInfo._id);

        // Update email if it changed in Firebase
        if (userInfo.email !== email) {
          userInfo.email = email;
          try {
            await userInfo.save();
            console.log('[firebaseAuthMiddleware] Updated user email');
          } catch (updateError) {
            console.error('[firebaseAuthMiddleware] Error updating email:', updateError);
          }
        }
      }

      // Attach both Firebase and MongoDB user info to request
      req.user = {
        uid: firebaseUID,
        email: email,
        mongoId: userInfo._id,
        userRecord: userInfo, // Full user record if needed
      };

      console.log('[firebaseAuthMiddleware] User sync completed:', {
        firebaseUID,
        mongoId: userInfo._id,
        email,
      });

      next();
    } catch (verifyErr) {
      console.error('[firebaseAuthMiddleware] Token verification failed:', verifyErr);
      return res.status(401).json({
        message: 'Invalid or expired token',
        error: verifyErr.message,
      });
    }
  } catch (err) {
    console.error('[firebaseAuthMiddleware] Middleware error:', err.message);
    return res.status(500).json({
      message: 'Auth middleware error',
      error: err.message,
    });
  }
};

// Optional: Helper function to get user info by Firebase UID
export const getUserByFirebaseUID = async (firebaseUID) => {
  try {
    const userInfo = await UserInfo.findOne({ userID: firebaseUID });
    return userInfo;
  } catch (error) {
    console.error('[getUserByFirebaseUID] Error:', error);
    return null;
  }
};

// Optional: Helper function to get user info by MongoDB ObjectID
export const getUserByMongoID = async (mongoId) => {
  try {
    const userInfo = await UserInfo.findById(mongoId);
    return userInfo;
  } catch (error) {
    console.error('[getUserByMongoID] Error:', error);
    return null;
  }
};
