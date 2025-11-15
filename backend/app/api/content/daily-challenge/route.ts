import { NextRequest, NextResponse } from 'next/server';

// This returns a daily challenge configuration
// In production, this could be dynamically generated or pulled from database
export async function GET(req: NextRequest) {
  try {
    // Generate daily challenge based on date
    const today = new Date();
    const dayOfYear = Math.floor((today.getTime() - new Date(today.getFullYear(), 0, 0).getTime()) / 86400000);

    // Rotate through different challenge types
    const challengeTypes = [
      { type: 'distance', name: 'Marathon Runner', description: 'Run 1000 meters', target: 1000, reward: 'gold_medal' },
      { type: 'score', name: 'High Score Hero', description: 'Score 5000 points', target: 5000, reward: 'diamond_trophy' },
      { type: 'jumps', name: 'Jump Master', description: 'Make 100 perfect jumps', target: 100, reward: 'spring_shoes' },
      { type: 'speed', name: 'Speed Demon', description: 'Complete track under 60 seconds', target: 60, reward: 'rocket_boost' },
    ];

    const todayChallenge = challengeTypes[dayOfYear % challengeTypes.length];

    return NextResponse.json({
      challenge: {
        ...todayChallenge,
        date: today.toISOString().split('T')[0],
        expiresAt: new Date(today.getTime() + 86400000).toISOString(),
      },
    });

  } catch (error) {
    console.error('Get daily challenge error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
