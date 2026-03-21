import {Suspense} from 'react'
import Image from 'next/image'
import {getAllPosts} from '@/lib/markdown'
import type {Post} from '@/types/post'
import FilterableGrid from '@/components/FilterableGrid'

export default async function HomePage() {
  const posts = await getAllPosts()
  const filteredPosts = posts.filter((post): post is Post => post !== null)
  const sortedPosts = filteredPosts.sort((a: Post, b: Post) => {
    return new Date(b.frontmatter.date).getTime() - new Date(a.frontmatter.date).getTime()
  })

  const allTags = Array.from(
    new Set(
      sortedPosts.flatMap(post => post.frontmatter.tags)
    )
  ).sort()

  return (
    <main className="min-h-screen bg-background">
      <div className="container mx-auto px-4 py-8 max-w-6xl">
        <div className="mb-4 flex flex-col sm:flex-row items-center justify-center gap-4 sm:gap-8">
          <div className="mascot-hero p-2">
            <Image
              src="/images/Front.png"
              alt="A towhee bird on a branch saying Comics! Illustration!"
              width={160}
              height={227}
              className="flex-shrink-0"
              priority
            />
          </div>
          <div className="text-center sm:text-left">
            <h1 className="text-5xl sm:text-7xl font-bold mb-2 pb-2 border-b text-foreground border-border">
              <span className="text-2xl sm:text-4xl mb-1 font-normal block text-muted">the art of</span>
              Chandu Tennety
            </h1>
            <p className="text-lg sm:text-xl text-muted">Independent comic creator, cartoonist and illustrator</p>
          </div>
        </div>
        {sortedPosts.length === 0 ? (
          <p className="text-center py-12 text-muted">No posts yet. Create your first one in the editor!</p>
        ) : (
          <Suspense>
            <FilterableGrid posts={sortedPosts} allTags={allTags} />
          </Suspense>
        )}
      </div>
    </main>
  )
}
