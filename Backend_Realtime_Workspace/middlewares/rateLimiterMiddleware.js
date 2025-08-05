import rateLimit from 'express-rate-limit';

// In-memory debounce tracker (replace with Redis in production)
const lastRequestTime = new Map();

// Helper to extract real IP
function getClientIP(req) {
  const xForwardedFor = req.headers['x-forwarded-for'];
  if (typeof xForwardedFor === 'string') {
    return xForwardedFor.split(',')[0].trim(); // First IP in the list
  }
  return req.ip || req.connection?.remoteAddress || req.socket?.remoteAddress || req.connection?.socket?.remoteAddress || 'unknown';
}

// Global rate limiter: 100 requests / 15 min
const baseRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit per IP
  message: {
    success: false,
    message: 'Too many requests, please slow down.'
  },
  keyGenerator: (req) => getClientIP(req) // use real IP as key
});

// Custom debounce function: e.g., 300ms delay between requests per IP
const debounceMiddleware = (req, res, next) => {
  const ip = getClientIP(req);
  const now = Date.now();
  const minInterval = 300; // 300 milliseconds

  const lastTime = lastRequestTime.get(ip) || 0;

  if (now - lastTime < minInterval) {
    return res.status(429).json({
      success: false,
      message: `You're clicking too fast. Please slow down.`
    });
  }

  lastRequestTime.set(ip, now);
  next();
};

// Combine both into one middleware array
const globalLimiter = [debounceMiddleware, baseRateLimiter];

export default globalLimiter;
