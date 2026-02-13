import path from 'path';
import fs from 'fs';
import multer from 'multer';
import { ApiError } from '../utils/ApiError';

const uploadDir = path.resolve(process.env.UPLOAD_DIR || 'uploads');

const ensureDir = (dir: string) => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
};

export const createUploadMiddleware = () => {
  const storage = multer.diskStorage({
    destination: (req, file, cb) => {
      const vendorId = req.user?.id || 'anonymous';
      const productId = req.params.id || 'unknown';
      const dest = path.join(uploadDir, 'products', vendorId, productId);
      ensureDir(dest);
      cb(null, dest);
    },
    filename: (req, file, cb) => {
      const safeName = file.originalname.replace(/[^a-zA-Z0-9.-]/g, '-');
      cb(null, `${Date.now()}-${safeName}`);
    }
  });

  const fileFilter = (
    _req: Express.Request,
    file: Express.Multer.File,
    cb: multer.FileFilterCallback
  ) => {
    const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedMimeTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new ApiError(400, 'VALIDATION_ERROR', 'Invalid file type. Only JPEG, PNG, and WebP images are allowed.'));
    }
  };

  return multer({
    storage,
    fileFilter,
    limits: { fileSize: 5 * 1024 * 1024, files: 5 }
  });
};
