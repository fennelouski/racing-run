import { NextRequest, NextResponse } from 'next/server';
import { initDB } from '@/lib/db';

// Database initialization endpoint
// Call this once to set up tables
// In production, protect this with admin authentication
export async function POST(req: NextRequest) {
  try {
    // Simple protection - require a secret key
    const { searchParams } = new URL(req.url);
    const secret = searchParams.get('secret');

    if (secret !== process.env.INIT_DB_SECRET) {
      return NextResponse.json(
        { error: 'Unauthorized' },
        { status: 401 }
      );
    }

    await initDB();

    return NextResponse.json({
      message: 'Database initialized successfully',
    });

  } catch (error) {
    console.error('Database init error:', error);
    return NextResponse.json(
      { error: 'Failed to initialize database' },
      { status: 500 }
    );
  }
}
