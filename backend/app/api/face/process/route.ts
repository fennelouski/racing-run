import { NextRequest, NextResponse } from 'next/server';
import sharp from 'sharp';

// Process face image - crop, resize, and optimize
export async function POST(req: NextRequest) {
  try {
    const formData = await req.formData();
    const imageFile = formData.get('image') as File;

    if (!imageFile || !imageFile.type.startsWith('image/')) {
      return NextResponse.json(
        { error: 'Valid image file is required' },
        { status: 400 }
      );
    }

    // Convert File to Buffer
    const arrayBuffer = await imageFile.arrayBuffer();
    const buffer = Buffer.from(arrayBuffer);

    // Process image with sharp
    const processedImage = await sharp(buffer)
      .resize(512, 512, { // Resize to standard size
        fit: 'cover',
        position: 'center',
      })
      .png({ quality: 90 }) // Convert to PNG with good quality
      .toBuffer();

    // Return processed image
    return new NextResponse(processedImage, {
      headers: {
        'Content-Type': 'image/png',
        'Content-Length': processedImage.length.toString(),
      },
    });

  } catch (error) {
    console.error('Face processing error:', error);
    return NextResponse.json(
      { error: 'Failed to process image' },
      { status: 500 }
    );
  }
}
