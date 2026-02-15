import {NextRequest, NextResponse} from 'next/server'
import fs from 'fs'
import path from 'path'

export async function POST(req: NextRequest) {
  const formData = await req.formData()
  const file = formData.get('file') as File

  if (!file) {
    return NextResponse.json({error: 'No file provided'}, {status: 400})
  }

  const uploadsDir = path.join(process.cwd(), 'public', 'uploads')
  if (!fs.existsSync(uploadsDir)) {
    fs.mkdirSync(uploadsDir, {recursive: true})
  }

  const filename = `${Date.now()}-${file.name}`
  const filePath = path.join(uploadsDir, filename)
  const buffer = await file.arrayBuffer()
  fs.writeFileSync(filePath, Buffer.from(buffer))

  return NextResponse.json({url: `/uploads/${filename}`})
}
