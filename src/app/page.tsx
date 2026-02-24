import Link from 'next/link'
import Image from 'next/image'
import {getAllPosts} from '@/lib/markdown'
import type {Post} from '@/types/post'

export default async function HomePage() {
  const posts = await getAllPosts()
  const filteredPosts = posts.filter((post): post is Post => post !== null)
  const sortedPosts = filteredPosts.sort((a: Post, b: Post) => {
    return new Date(b.frontmatter.date as string).getTime() - new Date(a.frontmatter.date as string).getTime()
  })
  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-950">
      <div className="container mx-auto px-4 py-16 max-w-6xl">
        <div className="mb-12">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-gray-50 mb-2">Chandu Tennety</h1>
          <p className="text-lg text-gray-600 dark:text-gray-400">Independent comic creator, cartoonist and illustrator</p>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {sortedPosts.length === 0 ? (
            <p className="text-center text-gray-500 dark:text-gray-400 py-12">No posts yet. Create your first one in the editor!</p>
          ) : (
            sortedPosts.map((post: Post) => {
              const postImages = Array.isArray(post.frontmatter.images) ? post.frontmatter.images : []
              const imageSrc = (post.frontmatter.thumb as string) ?? (postImages.length > 0 ? postImages[0] : null)
              return (
                <Link key={post.slug} href={`/${post.slug}`}>
                  <div className="group relative rounded-lg shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600 overflow-hidden cursor-pointer aspect-[4/3] bg-gray-100 dark:bg-gray-900">
                    {imageSrc ? (
                      <Image
                        src={imageSrc}
                        alt={(post.frontmatter.title as string) || post.slug}
                        fill
                        sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
                        className="object-cover transition-transform duration-300 group-hover:scale-110"
                        unoptimized
                      />
                    ) : null}
                    <div className="absolute inset-0 flex flex-col justify-end bg-gradient-to-t from-black/70 via-black/10 to-transparent p-5 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
                      <h4 className="text-white text-lg font-semibold mb-1 drop-shadow">
                        {post.frontmatter.title as string}
                      </h4>
                    </div>
                  </div>
                </Link>
              )
            })
          )}
        </div>
      </div>
    </main>
  )
}
