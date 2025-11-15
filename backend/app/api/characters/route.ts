import { NextRequest, NextResponse } from 'next/server';
import { put } from '@vercel/blob';
import { sql } from '@/lib/db';
import { requireAuth } from '@/lib/auth';
import { CreateCharacterSchema } from '@/lib/validation';

// GET all characters for authenticated user
export async function GET(req: NextRequest) {
  try {
    const user = requireAuth(req);

    const result = await sql`
      SELECT id, user_id, name, image_url, created_at, updated_at
      FROM characters
      WHERE user_id = ${user.userId}
      ORDER BY created_at DESC
    `;

    return NextResponse.json({
      characters: result.rows,
    });

  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    console.error('Get characters error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}

// POST create new character
export async function POST(req: NextRequest) {
  try {
    const user = requireAuth(req);

    const formData = await req.formData();
    const name = formData.get('name') as string;
    const imageFile = formData.get('image') as File;

    // Validate inputs
    const validation = CreateCharacterSchema.safeParse({ name });
    if (!validation.success) {
      return NextResponse.json(
        { error: 'Invalid name', details: validation.error.errors },
        { status: 400 }
      );
    }

    if (!imageFile || !imageFile.type.startsWith('image/')) {
      return NextResponse.json(
        { error: 'Valid image file is required' },
        { status: 400 }
      );
    }

    // Upload image to Vercel Blob
    const filename = `characters/${user.userId}/${Date.now()}-${imageFile.name}`;
    const blob = await put(filename, imageFile, {
      access: 'public',
      addRandomSuffix: true,
    });

    // Save character to database
    const result = await sql`
      INSERT INTO characters (user_id, name, image_url)
      VALUES (${user.userId}, ${name}, ${blob.url})
      RETURNING id, user_id, name, image_url, created_at, updated_at
    `;

    return NextResponse.json({
      character: result.rows[0],
    }, { status: 201 });

  } catch (error: any) {
    if (error.message === 'Unauthorized') {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
    }
    console.error('Create character error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
