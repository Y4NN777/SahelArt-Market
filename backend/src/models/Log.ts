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

logSchema.index({ actorId: 1 });
logSchema.index({ targetType: 1, targetId: 1 });
logSchema.index({ createdAt: -1 });

export const Log = mongoose.model('Log', logSchema);
