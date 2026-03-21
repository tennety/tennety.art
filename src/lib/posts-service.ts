import fs from 'fs'
import path from 'path'
import matter from 'gray-matter'
import {POSTS_DIR} from '@/lib/constants'
import type {PostFrontmatter, PostSummary} from '@/types/post'

function normalizeFrontmatter(data: Record<string, unknown>): PostFrontmatter {
  return {
    title: typeof data.title === 'string' ? data.title : '',
    date: typeof data.date === 'string' ? data.date : '',
    tags: Array.isArray(data.tags) ? data.tags : [],
    images: Array.isArray(data.images) ? data.images : [],
    thumb: typeof data.thumb === 'string' ? data.thumb : undefined,
    'shop-link': typeof data['shop-link'] === 'string' ? data['shop-link'] : undefined,
    ...data,
  }
}

export function getPostSlugs(): string[] {
  return fs.readdirSync(POSTS_DIR).filter((f) => f.endsWith('.md'))
}

export function readPostFile(slug: string): {frontmatter: PostFrontmatter; rawContent: string} | null {
  const realSlug = slug.replace(/\.md$/, '')
  const fullPath = path.join(POSTS_DIR, `${realSlug}.md`)
  if (!fs.existsSync(fullPath)) return null
  const fileContents = fs.readFileSync(fullPath, 'utf8')
  const {data, content} = matter(fileContents)
  return {
    frontmatter: normalizeFrontmatter(data),
    rawContent: content,
  }
}

export function listPostSummaries(): PostSummary[] {
  const files = getPostSlugs()
  return files.map(f => {
    const slug = f.replace(/\.md$/, '')
    const fileContents = fs.readFileSync(path.join(POSTS_DIR, f), 'utf8')
    const {data} = matter(fileContents)
    return {slug, title: (typeof data.title === 'string' ? data.title : slug)}
  })
}

export function writePostFile(slug: string, body: string): void {
  if (!fs.existsSync(POSTS_DIR)) fs.mkdirSync(POSTS_DIR, {recursive: true})
  const filePath = path.join(POSTS_DIR, `${slug}.md`)
  fs.writeFileSync(filePath, body)
}
