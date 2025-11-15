import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@/lib/db';

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const limit = Math.min(parseInt(searchParams.get('limit') || '10'), 100);
    const offset = parseInt(searchParams.get('offset') || '0');
    const gameMode = searchParams.get('gameMode') || 'endless';

    // Get top scores with user and character information
    const result = await sql`
      SELECT
        s.id,
        s.score,
        s.distance,
        s.game_mode,
        s.created_at,
        u.id as user_id,
        u.username,
        c.id as character_id,
        c.name as character_name,
        c.image_url as character_image
      FROM scores s
      JOIN users u ON s.user_id = u.id
      LEFT JOIN characters c ON s.character_id = c.id
      WHERE s.game_mode = ${gameMode}
      ORDER BY s.score DESC, s.created_at ASC
      LIMIT ${limit}
      OFFSET ${offset}
    `;

    return NextResponse.json({
      leaderboard: result.rows,
      limit,
      offset,
      gameMode,
    });

  } catch (error) {
    console.error('Get leaderboard error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
