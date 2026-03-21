import {remark} from 'remark'
import html from 'remark-html'
import {getPostSlugs, readPostFile} from '@/lib/posts-service'
import type {Post} from '@/types/post'

export {getPostSlugs}

export async function getPostBySlug(slug?: string): Promise<Post | null> {
  if (!slug || typeof slug !== 'string') return null

  const result = readPostFile(slug)
  if (!result) return null

  const processedContent = await remark().use(html).process(result.rawContent)
  return {
    slug: slug.replace(/\.md$/, ''),
    frontmatter: result.frontmatter,
    content: processedContent.toString(),
  }
}

export async function getAllPosts(): Promise<(Post | null)[]> {
  const slugs = getPostSlugs()
  return Promise.all(slugs.map((slug) => getPostBySlug(slug)))
}
