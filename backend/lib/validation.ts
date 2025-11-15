import { z } from 'zod';

export const RegisterSchema = z.object({
  email: z.string().email(),
  username: z.string().min(3).max(100),
  password: z.string().min(6).max(100),
});

export const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

export const CreateCharacterSchema = z.object({
  name: z.string().min(1).max(100),
  // image will be validated separately as multipart/form-data
});

export const SubmitScoreSchema = z.object({
  characterId: z.string().uuid().optional(),
  score: z.number().int().min(0),
  distance: z.number().int().min(0),
  gameMode: z.string().max(50).default('endless'),
});

export const LeaderboardQuerySchema = z.object({
  limit: z.number().int().min(1).max(100).default(10),
  offset: z.number().int().min(0).default(0),
  gameMode: z.string().max(50).optional(),
});
