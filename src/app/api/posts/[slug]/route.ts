import {NextRequest, NextResponse} from 'next/server'
import {getPostSlugs, readPostFile} from '@/lib/posts-service'

export const dynamic = 'force-static'

export async function generateStaticParams() {
  return getPostSlugs().map(f => ({slug: f.replace(/\.md$/, '')}))
}

export async function GET(req: NextRequest, ctx: {params: Promise<{slug: string}>}) {
  const {slug} = await ctx.params
  const result = readPostFile(slug)
  if (!result) return NextResponse.json({error: 'Not found'}, {status: 404})
  return NextResponse.json({frontmatter: result.frontmatter, content: result.rawContent})
}
