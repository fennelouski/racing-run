import { sql } from '@vercel/postgres';

// Database schema will be created via Vercel Postgres
// Tables: users, characters, scores, content

export interface User {
  id: string;
  email: string;
  username: string;
  password_hash: string;
  created_at: Date;
}

export interface Character {
  id: string;
  user_id: string;
  name: string;
  image_url: string;
  created_at: Date;
  updated_at: Date;
}

export interface Score {
  id: string;
  user_id: string;
  character_id: string;
  score: number;
  distance: number;
  game_mode: string;
  created_at: Date;
}

export interface ContentItem {
  id: string;
  type: 'costume' | 'track' | 'challenge';
  name: string;
  description: string;
  data_url: string;
  is_premium: boolean;
  created_at: Date;
}

// Initialize database tables
export async function initDB() {
  try {
    // Users table
    await sql`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        username VARCHAR(100) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // Characters table
    await sql`
      CREATE TABLE IF NOT EXISTS characters (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(100) NOT NULL,
        image_url TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // Scores table
    await sql`
      CREATE TABLE IF NOT EXISTS scores (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        character_id UUID REFERENCES characters(id) ON DELETE SET NULL,
        score INTEGER NOT NULL,
        distance INTEGER NOT NULL,
        game_mode VARCHAR(50) DEFAULT 'endless',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // Content table
    await sql`
      CREATE TABLE IF NOT EXISTS content (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        type VARCHAR(20) NOT NULL,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        data_url TEXT NOT NULL,
        is_premium BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `;

    // Create indexes
    await sql`CREATE INDEX IF NOT EXISTS idx_characters_user_id ON characters(user_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_scores_user_id ON scores(user_id)`;
    await sql`CREATE INDEX IF NOT EXISTS idx_scores_score ON scores(score DESC)`;

    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Database initialization error:', error);
    throw error;
  }
}

export { sql };
