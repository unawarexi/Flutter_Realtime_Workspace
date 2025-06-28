import admin from 'firebase-admin';

export const sendFCM = async (fcmToken, code) => {
  const message = {
    token: fcmToken,
    notification: {
      title: 'Your 2FA Code',
      body: `Your verification code is: ${code}`,
    },
    data: {
      code: code,
    },
  };

  try {
    const response = await admin.messaging().send(message);
    return { success: true, response };
  } catch (error) {
    return { success: false, error: error.message };
  }
};
