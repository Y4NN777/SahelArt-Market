import mongoose, { Schema } from 'mongoose';

const profileSchema = new Schema(
  {
    firstName: { type: String, required: true },
    lastName: { type: String, required: true },
    phone: { type: String },
    address: { type: String }
  },
  { _id: false }
);

const userSchema = new Schema(
  {
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ['customer', 'vendor', 'admin'], required: true },
    profile: { type: profileSchema, required: true },
    status: { type: String, enum: ['active', 'suspended'], default: 'active' }
  },
  { timestamps: true }
);

userSchema.set('toJSON', {
  transform: (_doc: any, ret: any) => {
    const { passwordHash: _passwordHash, ...rest } = ret;
    return rest;
  }
});

export const User = mongoose.model('User', userSchema);
