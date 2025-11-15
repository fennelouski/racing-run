import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@/lib/db';
import { requireAuth } from '@/lib/auth';
import { SubmitScoreSchema } from '@/lib/validation';

// POST submit score
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req);
    const body = await req.json();

    const validation = SubmitScoreSchema.safeParse(body);
    if (!validation.success) {
      return NextResponse.json(
        { error: 'Invalid input', details: validation.error.errors },
        { status: 400 }
      );
    }

    const { characterId, score, distance, gameMode } = validation.data;

    // If characterId provided, verify it belongs to user
    if (characterId) {
      const charCheck = await sql`
        SELECT id FROM characters
        WHERE id = ${characterId} AND user_id = ${user.userId}
      `;
      if (charCheck.rows.length === 0) {
        return NextResponse.json(
          { error: 'Character not found or does not belong to user' },
          { status: 404 }
        );
      }
    }

    // Insert score
    const result = await sql`
      INSERT INTO scores (user_id, character_id, score, distance, game_mode)
      VALUES (${user.userId}, ${characterId || null}, ${score}, ${distance}, ${gameMode})
      RETURNING id, user_id, character_id, score, distance, game_mode, created_at
    `;

    // Get user's rank for this game mode
    const rankResult = await sql`
      SELECT COUNT(*) + 1 as rank
      FROM scores
      WHERE game_mode = ${gameMode} AND score > ${score}
    `;

    return NextResponse.json({
      score: result.rows[0],
      rank: parseInt(rankResult.rows[0].rank),
    }, { status: 201 });

  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    console.error('Submit score error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// GET user's scores
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req);
    const { searchParams } = new URL(req.url);
    const limit = Math.min(parseInt(searchParams.get('limit') || '20'), 100);

    const result = await sql`
      SELECT
        s.id,
        s.score,
        s.distance,
        s.game_mode,
        s.created_at,
        c.name as character_name,
        c.image_url as character_image
      FROM scores s
      LEFT JOIN characters c ON s.character_id = c.id
      WHERE s.user_id = ${user.userId}
      ORDER BY s.created_at DESC
      LIMIT ${limit}
    `;

    return NextResponse.json({
      scores: result.rows,
    });

  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    console.error('Get scores error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
