import { Log } from '../models/Log';

export const LogRepository = {
  create: (data: Record<string, unknown>) => Log.create(data)
};
