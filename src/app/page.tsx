import {Suspense} from 'react'
import {getAllPosts} from '@/lib/markdown'
import type {Post} from '@/types/post'
import FilterableGrid from '@/components/FilterableGrid'

export default async function HomePage() {
  const posts = await getAllPosts()
  const filteredPosts = posts.filter((post): post is Post => post !== null)
  const sortedPosts = filteredPosts.sort((a: Post, b: Post) => {
    return new Date(b.frontmatter.date as string).getTime() - new Date(a.frontmatter.date as string).getTime()
  })

  const allTags = Array.from(
    new Set(
      sortedPosts.flatMap(post =>
        Array.isArray(post.frontmatter.tags) ? post.frontmatter.tags : []
      )
    )
  ).sort()

  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-950">
      <div className="container mx-auto px-4 py-8 max-w-6xl">
        <div className="mb-8 text-center">
          <h1 className="inline-block text-7xl font-bold text-gray-900 dark:text-gray-50 mb-3 pb-2 border-b border-gray-300 dark:border-gray-600">
            <span className="text-4xl text-gray-400 dark:text-gray-500 mb-1 block">the art of</span>
            Chandu Tennety
          </h1>
          <p className="text-xl text-gray-600 dark:text-gray-400">Independent comic creator, cartoonist and illustrator</p>
        </div>
        {sortedPosts.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-12">No posts yet. Create your first one in the editor!</p>
        ) : (
          <Suspense>
            <FilterableGrid posts={sortedPosts} allTags={allTags} />
          </Suspense>
        )}
      </div>
    </main>
  )
}
