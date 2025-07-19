import 'dotenv/config';
import mongoose from 'mongoose';
const MONGO_URI = process.env.MONGO_URI;

const connectDB = async () => {
  try {
    if (!MONGO_URI) {
      throw new Error('MONGO_URL environment variable is not defined');
    }

    await mongoose.connect(MONGO_URI);
    console.log(`MongoDB connected successfully`);
  } catch (err) {
    console.log('Database connection error:', err);
  }
};

export { connectDB };
