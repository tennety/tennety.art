import {NextRequest, NextResponse} from 'next/server'
import fs from 'fs'
import path from 'path'
import {UPLOADS_DIR} from '@/lib/constants'

export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('file') as File

  if (!file) {
    return NextResponse.json({error: 'No file provided'}, {status: 400})
  }

  if (!fs.existsSync(UPLOADS_DIR)) {
    fs.mkdirSync(UPLOADS_DIR, {recursive: true})
  }

  // Sanitize filename: strip path separators, keep only safe characters
  const safeName = file.name.replace(/[^a-zA-Z0-9._-]/g, '_')
  const filename = `${Date.now()}-${safeName}`
  const filePath = path.join(UPLOADS_DIR, filename)
  const buffer = await file.arrayBuffer()
  fs.writeFileSync(filePath, Buffer.from(buffer))

  return NextResponse.json({url: `/images/${filename}`})
}
