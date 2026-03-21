import {NextRequest, NextResponse} from 'next/server'
import {readPostFile} from '@/lib/posts-service'

export async function GET(req: NextRequest, ctx: {params: Promise<{slug: string}>}) {
  const {slug} = await ctx.params
  const result = readPostFile(slug)
  if (!result) return NextResponse.json({error: 'Not found'}, {status: 404})
  return NextResponse.json({frontmatter: result.frontmatter, content: result.rawContent})
}
