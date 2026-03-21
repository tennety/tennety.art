import Link from 'next/link'
import {getPostBySlug, getPostSlugs} from '@/lib/markdown'
import type {Post} from '@/types/post'
import type {Metadata} from 'next'
import {notFound} from 'next/navigation'
import {ArrowLeftIcon} from '@heroicons/react/24/outline'
import ImageGallery from '@/components/ImageGallery'

export async function generateStaticParams() {
  const files = getPostSlugs()
  const slugs = files.map((f: string) => f.replace(/\.md$/, ''))
  return slugs.map((slug: string) => ({slug}))
}
export const dynamicParams = false

export async function generateMetadata({params}: {params: Promise<{slug: string}>}): Promise<Metadata> {
  const {slug} = await params
  const post = await getPostBySlug(slug)
  if (!post) return {}

  const title = (post.frontmatter.title as string) || slug
  const images = Array.isArray(post.frontmatter.images) ? post.frontmatter.images : []
  const thumb = (post.frontmatter.thumb as string) || (images.length > 0 ? images[0] : undefined)

  return {
    title,
    description: `${title} — artwork by Chandu Tennety`,
    openGraph: {
      title,
      description: `${title} — artwork by Chandu Tennety`,
      type: 'article',
      publishedTime: post.frontmatter.date as string | undefined,
      ...(thumb ? {images: [{url: thumb}]} : {}),
    },
    twitter: {
      card: 'summary_large_image',
      title,
      ...(thumb ? {images: [thumb]} : {}),
    },
  }
}

export default async function PostPage({params}: {params: Promise<{slug: string}>}) {
  const {slug} = await params
  const post: Post | null = await getPostBySlug(slug)
  if (!post) return notFound()
  return (
    <article className="min-h-screen" style={{background: 'var(--background)'}}>
      <div className="container mx-auto px-4 py-12 max-w-3xl">
        <Link href="/" className="inline-flex items-center gap-1 mb-6 nav-link no-underline text-sm">
          <ArrowLeftIcon className="w-4 h-4" />
          Back to Posts
        </Link>
        <div className="mb-8">
          <h1 className="text-4xl font-bold mb-2" style={{color: 'var(--foreground)'}}>{post.frontmatter.title as string}</h1>
          <p style={{color: 'var(--muted)'}} className="mb-3">{new Date(post.frontmatter.date as string).toLocaleDateString('en-US', {year: 'numeric', month: 'long', day: 'numeric'})}</p>
          {Array.isArray(post.frontmatter.tags) && post.frontmatter.tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {(post.frontmatter.tags as string[]).map((tag: string) => (
                <span
                  key={tag}
                  className="inline-flex items-center px-3 py-1 text-sm rounded-full border"
                  style={{background: 'var(--surface)', color: 'var(--foreground)', borderColor: 'var(--border)'}}
                >
                  {tag}
                </span>
              ))}
            </div>
          )}
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
              className="buy-cta"
            >
              Buy this
            </a>
          </div>
        ) : null}

        <div className="prose prose-lg max-w-none post-prose [&>p]:my-4 [&>ul]:my-4 [&>ol]:my-4" dangerouslySetInnerHTML={{__html: post.content}} />
      </div>
    </article>
  )
}
