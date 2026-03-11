import {getAllPosts} from '@/lib/markdown'
import type {Post} from '@/types/post'
import PostTile from '@/components/PostTile'

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
        {sortedPosts.length === 0 ? (
          <p className="text-center text-gray-500 dark:text-gray-400 py-12">No posts yet. Create your first one in the editor!</p>
        ) : (
          <div className="flex flex-col gap-4">
            {sortedPosts.reduce<Post[][]>((acc, post, i) => {
              if (i % 2 === 0) acc.push([post])
              else acc[acc.length - 1].push(post)
              return acc
            }, []).map((pair, rowIdx) => (
              <div
                key={rowIdx}
                className={`grid gap-4 ${rowIdx % 2 === 0 ? 'grid-cols-[1.6fr_1fr]' : 'grid-cols-[1fr_1.6fr]'}`}
              >
                {pair.map((post: Post, tileIdx: number) => (
                  <PostTile key={post.slug} post={post} isLarge={rowIdx % 2 === tileIdx % 2} />
                ))}
              </div>
            ))}
          </div>
        )}
      </div>
    </main>
  )
}
