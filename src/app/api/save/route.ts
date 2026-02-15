import {NextRequest, NextResponse} from 'next/server'
import fs from 'fs'
import path from 'path'

export async function POST(req: NextRequest) {
  const {body, slug} = await req.json()
  const postsDir = path.join(process.cwd(), 'content', 'posts')
  if (!fs.existsSync(postsDir)) fs.mkdirSync(postsDir, {recursive: true})
  const filePath = path.join(postsDir, `${slug}.md`)
  fs.writeFileSync(filePath, body)
  return NextResponse.json({ok: true})
}
