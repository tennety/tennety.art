import Link from 'next/link'
import {getAllPosts} from '@/lib/markdown'

export default async function HomePage() {
  const posts = await getAllPosts()
  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-950">
      <div className="container mx-auto px-4 py-16 max-w-4xl">
        <div className="mb-12">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-gray-50 mb-2">My Illustrations</h1>
          <p className="text-lg text-gray-600 dark:text-gray-400">A collection of digital artwork and creative projects</p>
        </div>
        <div className="grid gap-6">
          {posts.length === 0 ? (
            <p className="text-center text-gray-500 dark:text-gray-400 py-12">No posts yet. Create your first one in the editor!</p>
          ) : (
            posts.map((post: any) => (
              <Link key={post.slug} href={`/${post.slug}`}>
                <div className="group bg-white dark:bg-gray-800 rounded-lg shadow-sm hover:shadow-lg transition-all duration-300 border border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600 p-6 cursor-pointer">
                  <h2 className="text-2xl font-semibold text-gray-900 dark:text-gray-50 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors mb-2">
                    {post.frontmatter.title}
                  </h2>
                  <p className="text-sm text-gray-500 dark:text-gray-400">{new Date(post.frontmatter.date).toLocaleDateString('en-US', {year: 'numeric', month: 'long', day: 'numeric'})}</p>
                </div>
              </Link>
            ))
          )}
        </div>
      </div>
    </main>
  )
}
