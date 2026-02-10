import mongoose from 'mongoose';

export const connectDatabase = async () => {
  const uri = process.env.MONGO_URI || 'mongodb://localhost:27017/sahelart';
  await mongoose.connect(uri);
  return mongoose.connection;
};
