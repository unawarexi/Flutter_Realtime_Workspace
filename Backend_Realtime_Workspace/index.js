// app.js

import express from "express";
import morgan from "morgan";
import cookieParser from "cookie-parser";
import cors from "cors";
import dotenv from "dotenv";
import { connectDB } from "./config/mongoConfig.js";

// Import routes
// import authRoutes from './routes/authRoutes.js';
// import userRoutes from './routes/userRoutes/userRoutes.js';
// import chatRoutes from './routes/chatRoutes.js';
import userInfoRoutes from "./routes/userInfoRoutes.js";
import fcmRoutes from "./routes/fcmRoutes.js";
import projectRoutes from "./routes/projectRoutes.js"; 
import teamRoutes from "./routes/teamRoutes.js"; 

// Load environment variables
dotenv.config();

// Create Express app
const app = express();

// Middleware
app.use(
  cors({
    origin: "*",
    credentials: true,
  })
);
app.use(express.json());
app.use(cookieParser());

// Development logging
if (process.env.NODE_ENV === "development") {
  app.use(morgan("dev"));
}

app.use((req, res, next) => {
  console.log(
    `[${new Date().toISOString()}] ${req.method} ${req.path} - Body size: ${req.get("content-length") || 0} bytes`
  );
  next();
});

// Routes
// app.use('/api/v1/auth', authRoutes);
// app.use('/api/v1/users', userRoutes);
// app.use('/api/v1/chats', chatRoutes); // Add this line
app.use("/api/v1/userinfo", userInfoRoutes);
app.use("/api/v1/fcm", fcmRoutes);
app.use("/api/v1/projects", projectRoutes); 
app.use("/api/v1/teams", teamRoutes);




// Error handling middleware
app.use((req, res, next) => {
  res.status(404).json({
    status: "fail",
    message: `Can't find ${req.originalUrl} on this server!`,
  });
});

app.use((err, req, res, next) => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || "error";

  res.status(err.statusCode).json({
    status: err.status,
    message: err.message,
  });
});

const PORT = process.env.PORT;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server started at port ${PORT}`);
  connectDB();
});

export default app;
