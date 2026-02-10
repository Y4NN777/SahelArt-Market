import mongoose, { Schema } from 'mongoose';

const logSchema = new Schema(
  {
    actorId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    action: { type: String, required: true },
    targetType: { type: String, required: true },
    targetId: { type: Schema.Types.ObjectId, required: true },
    meta: { type: Schema.Types.Mixed }
  },
  { timestamps: true }
);

export const Log = mongoose.model('Log', logSchema);
