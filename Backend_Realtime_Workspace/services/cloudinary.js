import { v2 as cloudinary } from "cloudinary";
import * as dotenv from "dotenv";
import multer from "multer";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";
import { extensionToMimeType, allowedExtensions } from "../utils/extensions.js";

// Load environment variables
dotenv.config();

// Get __dirname equivalent in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configure cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

// Configure multer for temporary file storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadsDir = path.join(__dirname, "../uploads");
    // Ensure uploads directory exists
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    // Create unique filename with original extension
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + "-" + uniqueSuffix + ext);
  },
});

// Enhanced file filter for all media types
const fileFilter = (req, file, cb) => {
  // Get file extension for validation
  const fileExtension = path.extname(file.originalname).toLowerCase();

  

  // Flatten all allowed extensions
  const allAllowedExtensions = Object.values(allowedExtensions).flat();

  

  const allowedMimeTypes = Object.values(extensionToMimeType);

  // Debug logging
  console.log("File details:", {
    originalname: file.originalname,
    mimetype: file.mimetype,
    extension: fileExtension,
    size: file.size,
  });

  // Check if extension is valid
  const isExtensionValid = allAllowedExtensions.includes(fileExtension);

  if (!isExtensionValid) {
    console.log("File rejected - invalid extension:", {
      mimetype: file.mimetype,
      extension: fileExtension,
      isExtensionValid,
    });
    cb(
      new Error(
        `Invalid file extension: ${fileExtension}. Please upload a supported file type.`
      )
    );
    return;
  }

  // Check MIME type, but allow fallback for application/octet-stream
  const isMimeTypeValid = allowedMimeTypes.includes(file.mimetype);
  const isGenericMimeType = file.mimetype === "application/octet-stream";
  const expectedMimeType = extensionToMimeType[fileExtension];

  if (isMimeTypeValid || (isGenericMimeType && expectedMimeType)) {
    // If it's a generic MIME type but valid extension, update the MIME type
    if (isGenericMimeType && expectedMimeType) {
      console.log(
        `Correcting MIME type from ${file.mimetype} to ${expectedMimeType} based on extension ${fileExtension}`
      );
      file.mimetype = expectedMimeType;
    }
    cb(null, true);
  } else {
    console.log("File rejected - invalid MIME type:", {
      mimetype: file.mimetype,
      extension: fileExtension,
      expectedMimeType,
      isMimeTypeValid,
      isGenericMimeType,
    });
    cb(
      new Error(
        `Invalid file type. Received: ${file.mimetype} (${fileExtension}). Expected: ${expectedMimeType || "valid file MIME type"}.`
      )
    );
  }
};

// Initialize multer upload with enhanced settings
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 20 * 1024 * 1024, // 100MB limit for videos and large files
  },
});

// Multer error handler middleware
export function multerErrorHandler(err, req, res, next) {
  console.error("Multer error:", err);

  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        status: "error",
        message: "File too large. Maximum size is 100MB.",
      });
    }
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  } else if (err) {
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
  next();
}

/**
 * Determine the resource type based on file extension
 */
const getResourceType = (filePath) => {
  const ext = path.extname(filePath).toLowerCase();

  const imageExts = [
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".webp",
    ".bmp",
    ".tiff",
    ".svg",
    ".ico",
    ".heic",
    ".heif",
  ];
  const videoExts = [
    ".mp4",
    ".avi",
    ".mov",
    ".wmv",
    ".flv",
    ".webm",
    ".mkv",
    ".m4v",
    ".3gp",
    ".ogv",
  ];
  const audioExts = [
    ".mp3",
    ".wav",
    ".flac",
    ".aac",
    ".ogg",
    ".wma",
    ".m4a",
    ".opus",
    ".aiff",
  ];

  if (imageExts.includes(ext)) return "image";
  if (videoExts.includes(ext)) return "video";
  if (audioExts.includes(ext)) return "video"; // Cloudinary treats audio as video resource type
  return "raw"; // For documents and other files
};

/**
 * Upload any file type to Cloudinary
 * @param filePath - Path to the local file
 * @param folder - Cloudinary folder to upload to
 * @param originalName - Original filename for metadata
 * @returns Promise resolving to the Cloudinary upload result with metadata
 */
export const uploadToCloudinary = async (
  filePath,
  folder = "/projects/workspace",
  originalName = ""
) => {
  try {
    console.log("Uploading to Cloudinary:", filePath);

    const resourceType = getResourceType(filePath);
    const fileExtension = path.extname(filePath).toLowerCase();
    const fileName = path.basename(originalName || filePath, fileExtension);

    const uploadOptions = {
      folder: folder,
      resource_type: resourceType,
      public_id: `${fileName}_${Date.now()}`,
      use_filename: true,
      unique_filename: true,
    };

    // Add transformations for images and videos
    if (resourceType === "image") {
      uploadOptions.transformation = [
        { width: 1000, height: 1000, crop: "limit" },
        { quality: "auto" },
        { fetch_format: "auto" },
      ];
    } else if (resourceType === "video") {
      uploadOptions.transformation = [
        { quality: "auto" },
        { fetch_format: "auto" },
      ];
    }

    const result = await cloudinary.uploader.upload(filePath, uploadOptions);

    console.log("Cloudinary upload successful:", result.public_id);

    // Delete local file after upload
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    // Return comprehensive file information
    return {
      url: result.secure_url,
      public_id: result.public_id,
      resource_type: result.resource_type,
      format: result.format,
      bytes: result.bytes,
      width: result.width,
      height: result.height,
      duration: result.duration, // For video/audio files
      original_filename: result.original_filename,
      created_at: result.created_at,
      type: resourceType,
      filename: originalName || path.basename(filePath),
    };
  } catch (error) {
    console.error("Cloudinary upload error:", error);

    // Delete local file if upload failed
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }
    throw error;
  }
};

/**
 * Delete a file from Cloudinary
 * @param publicId - Public ID of the file to delete
 * @param resourceType - Type of resource (image, video, raw)
 * @returns Promise resolving to the deletion result
 */
export const deleteFromCloudinary = async (
  publicId,
  resourceType = "image"
) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType,
    });
    return result;
  } catch (error) {
    console.error("Error deleting from Cloudinary:", error);
    throw error;
  }
};

/**
 * Get optimized file URL with transformations
 * @param publicId - Public ID of the file
 * @param resourceType - Type of resource
 * @param transformations - Array of transformation objects
 * @returns Optimized file URL
 */
export const getOptimizedFileUrl = (
  publicId,
  resourceType = "image",
  transformations = []
) => {
  return cloudinary.url(publicId, {
    resource_type: resourceType,
    ...transformations,
    secure: true,
    quality: "auto",
    fetch_format: "auto",
  });
};

/**
 * Get file metadata from Cloudinary
 * @param publicId - Public ID of the file
 * @param resourceType - Type of resource
 * @returns File metadata
 */
export const getFileMetadata = async (publicId, resourceType = "image") => {
  try {
    const result = await cloudinary.api.resource(publicId, {
      resource_type: resourceType,
    });
    return result;
  } catch (error) {
    console.error("Error getting file metadata:", error);
    throw error;
  }
};
