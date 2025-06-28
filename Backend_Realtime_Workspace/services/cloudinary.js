import { v2 as cloudinary } from "cloudinary";
import * as dotenv from "dotenv";
import multer from "multer";
import * as fs from "fs";
import * as path from "path";
import { fileURLToPath } from "url";

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

// File filter for allowed image types
const fileFilter = (req, file, cb) => {
  // Get file extension for validation
  const fileExtension = path.extname(file.originalname).toLowerCase();
  const allowedExtensions = [
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".webp",
    ".bmp",
    ".tiff",
    ".svg",
  ];

  // Map extensions to MIME types for fallback detection
  const extensionToMimeType = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".bmp": "image/bmp",
    ".tiff": "image/tiff",
    ".svg": "image/svg+xml",
  };

  const allowedMimeTypes = [
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/webp",
    "image/bmp",
    "image/tiff",
    "image/svg+xml",
  ];

  // Debug logging
  console.log("File details:", {
    originalname: file.originalname,
    mimetype: file.mimetype,
    extension: fileExtension,
    size: file.size,
  });

  // Check if extension is valid
  const isExtensionValid = allowedExtensions.includes(fileExtension);

  if (!isExtensionValid) {
    console.log("File rejected - invalid extension:", {
      mimetype: file.mimetype,
      extension: fileExtension,
      isExtensionValid,
    });
    cb(
      new Error(
        `Invalid file extension: ${fileExtension}. Only .jpg, .jpeg, .png, .gif, .webp, .bmp, .tiff, and .svg files are allowed.`
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
        `Invalid file type. Received: ${file.mimetype} (${fileExtension}). Expected: ${expectedMimeType || "valid image MIME type"}.`
      )
    );
  }
};

// Initialize multer upload with error handling
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
});

// Multer error handler middleware for file type/size errors
export function multerErrorHandler(err, req, res, next) {
  console.error("Multer error:", err);

  if (err instanceof multer.MulterError) {
    // Multer-specific errors (e.g., file too large)
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        status: "error",
        message: "File too large. Maximum size is 5MB.",
      });
    }
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  } else if (err) {
    // Custom fileFilter errors
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
  next();
}

/**
 * Upload a file to Cloudinary
 * @param filePath - Path to the local file
 * @param folder - Cloudinary folder to upload to
 * @returns Promise resolving to the Cloudinary upload result
 */
export const uploadToCloudinary = async (
  filePath,
  folder = "/projects/workspace"
) => {
  try {
    console.log("Uploading to Cloudinary:", filePath);

    const result = await cloudinary.uploader.upload(filePath, {
      folder: folder,
      resource_type: "auto",
      upload_preset: "workspace",
      transformation: [
        { width: 500, height: 500, crop: "limit" }, // Resize large images
        { quality: "auto" }, // Optimize quality
        { fetch_format: "auto" }, // Use best format (WebP when supported)
      ],
    });

    console.log("Cloudinary upload successful:", result.public_id);

    // Delete local file after upload
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    return {
      url: result.secure_url,
      public_id: result.public_id,
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
 * @returns Promise resolving to the deletion result
 */
export const deleteFromCloudinary = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    return result;
  } catch (error) {
    console.error("Error deleting from Cloudinary:", error);
    throw error;
  }
};

/**
 * Get optimized image URL with transformations
 * @param publicId - Public ID of the image
 * @param transformations - Array of transformation objects
 * @returns Optimized image URL
 */
export const getOptimizedImageUrl = (publicId, transformations = []) => {
  return cloudinary.url(publicId, {
    ...transformations,
    secure: true,
    quality: "auto",
    fetch_format: "auto",
  });
};
