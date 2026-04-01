import {NextRequest, NextResponse} from 'next/server'
import {isValidSlug, sanitizeSlug} from '@/lib/validation'
import {writePostFile} from '@/lib/posts-service'

export const dynamic = 'force-static'

export async function GET() {
  return NextResponse.json({error: 'Not available'}, {status: 404})
}

export async function POST(req: NextRequest) {
  const {body, slug: rawSlug} = await req.json()
  if (typeof body !== 'string' || typeof rawSlug !== 'string') {
    return NextResponse.json({error: 'Invalid request body'}, {status: 400})
  }

  const slug = isValidSlug(rawSlug) ? rawSlug : sanitizeSlug(rawSlug)
  if (!slug) {
    return NextResponse.json({error: 'Invalid slug'}, {status: 400})
  }

  writePostFile(slug, body)
  return NextResponse.json({ok: true})
}
