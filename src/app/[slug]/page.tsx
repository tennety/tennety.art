import {getPostBySlug, getPostSlugs} from '@/lib/markdown'
import type {Post} from '@/types/post'
import {notFound} from 'next/navigation'

export async function generateStaticParams() {
  const files = getPostSlugs()
  const slugs = files.map((f: string) => f.replace(/\.md$/, ''))
  return slugs.map((slug: string) => ({slug}))
}
export const dynamicParams = false

export default async function PostPage({params}: {params: Promise<{slug: string}>}) {
  const {slug} = await params
  const post: Post | null = await getPostBySlug(slug)
  if (!post) return notFound()
  return (
    <article className="min-h-screen bg-white dark:bg-gray-950">
      <div className="container mx-auto px-4 py-12 max-w-3xl">
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-gray-900 dark:text-gray-50 mb-2">{post.frontmatter.title as string}</h1>
          <p className="text-gray-500 dark:text-gray-400">{new Date(post.frontmatter.date as string).toLocaleDateString('en-US', {year: 'numeric', month: 'long', day: 'numeric'})}</p>
        </div>
        <div className="prose dark:prose-invert prose-lg max-w-none" dangerouslySetInnerHTML={{__html: post.content}} />
      </div>
    </article>
  )
}
