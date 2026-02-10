import path from 'path';
import fs from 'fs';
import multer from 'multer';

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
      const safeName = file.originalname.replace(/\s+/g, '-');
      cb(null, `${Date.now()}-${safeName}`);
    }
  });

  return multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024, files: 5 }
  });
};
