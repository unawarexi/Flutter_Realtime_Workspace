import { createClient } from 'redis';

class RedisClient {
  constructor() {
    this.client = null;
    this.isConnected = false;
  }

  async connect() {
    try {
      this.client = createClient({
        url: process.env.REDIS_URL || 'redis://localhost:6379',
        socket: {
          connectTimeout: 60000,
          lazyConnect: true,
          reconnectStrategy: (retries) => {
            if (retries > 10) {
              return new Error('Redis connection failed after 10 retries');
            }
            return Math.min(retries * 50, 1000);
          }
        },
        // Connection pool settings
        database: 0,
        username: process.env.REDIS_USERNAME || undefined,
        password: process.env.REDIS_PASSWORD || undefined
      });

      // Event listeners
      this.client.on('error', (err) => {
        console.error('❌ Redis Error:', err);
        this.isConnected = false;
      });

      this.client.on('connect', () => {
        console.log('🔄 Connecting to Redis...');
      });

      this.client.on('ready', () => {
        console.log('✅ Redis connected and ready');
        this.isConnected = true;
      });

      this.client.on('end', () => {
        console.log('📴 Redis connection ended');
        this.isConnected = false;
      });

      this.client.on('reconnecting', () => {
        console.log('🔄 Redis reconnecting...');
      });

      await this.client.connect();
      return this.client;
    } catch (error) {
      console.error('Failed to connect to Redis:', error);
      throw error;
    }
  }

  // Enhanced set method with better error handling
  async set(key, value, options = {}) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }

      const serializedValue = typeof value === 'object' ? JSON.stringify(value) : String(value);

      if (options.EX) {
        return await this.client.setEx(key, options.EX, serializedValue);
      } else if (options.PX) {
        return await this.client.pSetEx(key, options.PX, serializedValue);
      } else if (options.NX) {
        return await this.client.setNX(key, serializedValue);
      } else {
        return await this.client.set(key, serializedValue);
      }
    } catch (error) {
      console.error(`Redis SET error for key ${key}:`, error);
      throw error;
    }
  }

  // Enhanced get method
  async get(key) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }

      const value = await this.client.get(key);
      if (value === null) return null;

      // Try to parse JSON, fallback to string
      try {
        return JSON.parse(value);
      } catch {
        return value;
      }
    } catch (error) {
      console.error(`Redis GET error for key ${key}:`, error);
      throw error;
    }
  }

  // Delete key
  async del(key) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      return await this.client.del(key);
    } catch (error) {
      console.error(`Redis DEL error for key ${key}:`, error);
      throw error;
    }
  }

  // Check if key exists
  async exists(key) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      return await this.client.exists(key);
    } catch (error) {
      console.error(`Redis EXISTS error for key ${key}:`, error);
      throw error;
    }
  }

  // Get TTL of a key
  async ttl(key) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      return await this.client.ttl(key);
    } catch (error) {
      console.error(`Redis TTL error for key ${key}:`, error);
      throw error;
    }
  }

  // Set expiration on existing key
  async expire(key, seconds) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      return await this.client.expire(key, seconds);
    } catch (error) {
      console.error(`Redis EXPIRE error for key ${key}:`, error);
      throw error;
    }
  }

  // Increment counter
  async incr(key) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      return await this.client.incr(key);
    } catch (error) {
      console.error(`Redis INCR error for key ${key}:`, error);
      throw error;
    }
  }

  // Hash operations for complex data
  async hset(key, field, value) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      const serializedValue = typeof value === 'object' ? JSON.stringify(value) : String(value);
      return await this.client.hSet(key, field, serializedValue);
    } catch (error) {
      console.error(`Redis HSET error for key ${key}:`, error);
      throw error;
    }
  }

  async hget(key, field) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      const value = await this.client.hGet(key, field);
      if (value === null) return null;

      try {
        return JSON.parse(value);
      } catch {
        return value;
      }
    } catch (error) {
      console.error(`Redis HGET error for key ${key}:`, error);
      throw error;
    }
  }

  async hgetAll(key) {
    try {
      if (!this.isConnected) {
        throw new Error('Redis not connected');
      }
      return await this.client.hGetAll(key);
    } catch (error) {
      console.error(`Redis HGETALL error for key ${key}:`, error);
      throw error;
    }
  }

  // Rate limiting helper
  async rateLimit(key, maxAttempts, windowSeconds) {
    try {
      const current = await this.incr(key);
      if (current === 1) {
        await this.expire(key, windowSeconds);
      }
      return {
        count: current,
        remaining: Math.max(0, maxAttempts - current),
        resetTime: await this.ttl(key)
      };
    } catch (error) {
      console.error(`Redis rate limit error for key ${key}:`, error);
      throw error;
    }
  }

  // Health check
  async ping() {
    try {
      if (!this.isConnected) {
        return false;
      }
      const result = await this.client.ping();
      return result === 'PONG';
    } catch (error) {
      console.error('Redis ping error:', error);
      return false;
    }
  }

  // Graceful shutdown
  async disconnect() {
    try {
      if (this.client && this.isConnected) {
        await this.client.quit();
        this.isConnected = false;
        console.log('📴 Redis connection closed gracefully');
      }
    } catch (error) {
      console.error('Error disconnecting from Redis:', error);
    }
  }

  // Get connection status
  getConnectionStatus() {
    return {
      connected: this.isConnected,
      client: !!this.client
    };
  }
}

// Create singleton instance
const redisClient = new RedisClient();

// Initialize connection
let connectionPromise = null;

export const initializeRedis = async () => {
  if (!connectionPromise) {
    connectionPromise = redisClient.connect();
  }
  return connectionPromise;
};

// Graceful shutdown handler
process.on('SIGINT', async () => {
  console.log('Received SIGINT, closing Redis connection...');
  await redisClient.disconnect();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  console.log('Received SIGTERM, closing Redis connection...');
  await redisClient.disconnect();
  process.exit(0);
});

export default redisClient;
