export const StorageService = {
  getPublicPath(relativePath: string) {
    return `/uploads/${relativePath}`.replace(/\\/g, '/');
  }
};
