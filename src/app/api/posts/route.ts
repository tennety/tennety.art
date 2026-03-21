import {NextResponse} from 'next/server'
import {listPostSummaries} from '@/lib/posts-service'

export const dynamic = 'force-static'

export async function GET() {
  const posts = listPostSummaries()
  return NextResponse.json({posts})
}
