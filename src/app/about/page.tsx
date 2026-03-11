import Link from 'next/link'

export default function AboutPage() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-950">
      <div className="container mx-auto px-4 py-16 max-w-2xl">
        <div className="mb-8 text-center">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-gray-50 mb-3 pb-2 border-b border-gray-300 dark:border-gray-600">About</h1>
          <p className="text-xl text-gray-600 dark:text-gray-400 mb-6">
            Hi! I&apos;m Chandu, an independent comics creator, cartoonist, and illustrator from Central Ohio.
          </p>
          <p className="text-md text-gray-700 dark:text-gray-300 mb-6">
            I love to tell emotionally resonant stories through the medium of comics, such as my YA series <span className='font-bold italic'>All Our Monsters</span>.
          </p>
          <p className="text-md text-gray-700 dark:text-gray-300 mb-6">
            I also create minicomics and single-issue comics. My work has been featured in various anthologies and exhibitions, and I&apos;m always looking for new opportunities to collaborate and share my art with the world.
          </p>
          <p className="text-md text-gray-700 dark:text-gray-300 mb-6">
            I update the site regularly with new content, so be sure to check back often!
          </p>
          <Link href="/" className="inline-block text-blue-600 dark:text-blue-300 hover:underline text-sm font-medium">&larr; Back to Home</Link>
        </div>
      </div>
    </main>
  )
}
