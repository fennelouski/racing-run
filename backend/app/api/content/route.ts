import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@/lib/db';

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const type = searchParams.get('type'); // 'costume', 'track', 'challenge'

    let query;
    if (type) {
      query = sql`
        SELECT id, type, name, description, data_url, is_premium, created_at
        FROM content
        WHERE type = ${type}
        ORDER BY created_at DESC
      `;
    } else {
      query = sql`
        SELECT id, type, name, description, data_url, is_premium, created_at
        FROM content
        ORDER BY type, created_at DESC
      `;
    }

    const result = await query;

    return NextResponse.json({
      content: result.rows,
    });

  } catch (error) {
    console.error('Get content error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
