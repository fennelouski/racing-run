import { NextRequest, NextResponse } from 'next/server';
import { del } from '@vercel/blob';
import { sql } from '@/lib/db';
import { requireAuth } from '@/lib/auth';

// GET single character
export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const user = requireAuth(req);
    const { id } = params;

    const result = await sql`
      SELECT id, user_id, name, image_url, created_at, updated_at
      FROM characters
      WHERE id = ${id} AND user_id = ${user.userId}
    `;

    if (result.rows.length === 0) {
      return NextResponse.json(
        { error: 'Character not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      character: result.rows[0],
    });

  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    console.error('Get character error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// DELETE character
export async function DELETE(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const user = requireAuth(req);
    const { id } = params;

    // Get character to delete blob
    const character = await sql`
      SELECT image_url FROM characters
      WHERE id = ${id} AND user_id = ${user.userId}
    `;

    if (character.rows.length === 0) {
      return NextResponse.json(
        { error: 'Character not found' },
        { status: 404 }
      );
    }

    // Delete from blob storage
    try {
      await del(character.rows[0].image_url);
    } catch (blobError) {
      console.error('Error deleting blob:', blobError);
      // Continue with database deletion even if blob deletion fails
    }

    // Delete from database
    await sql`
      DELETE FROM characters
      WHERE id = ${id} AND user_id = ${user.userId}
    `;

    return NextResponse.json({
      message: 'Character deleted successfully',
    });

  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    console.error('Delete character error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
