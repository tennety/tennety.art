import {getPostBySlug, getPostSlugs} from '@/lib/markdown'
import type {Post} from '@/types/post'
import {notFound} from 'next/navigation'
import ImageGallery from '@/components/ImageGallery'

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


        {(post.frontmatter.images as string[])?.length > 0 ? (
          <ImageGallery images={post.frontmatter.images as string[]} alt={post.frontmatter.title as string} />
        ) : null}

        {post.frontmatter["shop-link"] ? (
          <div className="mb-6">
            <a
              href={post.frontmatter["shop-link"] as string}
              target="_blank"
              rel="noopener noreferrer"
              className="block w-fit"
            >
              <span
                className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors text-sm font-medium shadow focus:outline-none focus:ring-2 focus:ring-blue-400 cursor-pointer"
                style={{ all: 'unset', display: 'inline-block', background: '#2563eb', color: '#fff', borderRadius: '0.375rem', padding: '0.5rem 1rem', fontWeight: 500, boxShadow: '0 1px 2px rgba(0,0,0,0.05)', transition: 'background 0.2s' }}
              >Buy this</span>
            </a>
          </div>
        ) : null}

        <div className="prose dark:prose-invert prose-lg max-w-none [&>p]:my-4 [&>ul]:my-4 [&>ol]:my-4" dangerouslySetInnerHTML={{__html: post.content}} />
      </div>
    </article>
  )
}
