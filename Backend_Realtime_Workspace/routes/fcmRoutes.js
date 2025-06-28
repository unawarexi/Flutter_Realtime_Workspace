import express from 'express';
import { sendFCM } from '../services/fcm.js';

const router = express.Router();

router.post('/send', async (req, res) => {
  const { fcmToken, code } = req.body;
  if (!fcmToken || !code) {
    return res.status(400).json({ success: false, message: 'Missing fcmToken or code' });
  }
  const result = await sendFCM(fcmToken, code);
  if (result.success) {
    res.json({ success: true, message: 'Notification sent', response: result.response });
  } else {
    res.status(500).json({ success: false, message: result.error });
  }
});

export default router;
