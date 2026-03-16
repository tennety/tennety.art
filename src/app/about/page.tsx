import Link from 'next/link'
import type {Metadata} from 'next'

export const metadata: Metadata = {
  title: 'About',
  description: 'Chandu Tennety is an independent comics creator, cartoonist, and illustrator from Central Ohio.',
  openGraph: {
    title: 'About Chandu Tennety',
    description: 'Independent comics creator, cartoonist, and illustrator from Central Ohio.',
  },
}

export default function AboutPage() {
  return (
    <main className="min-h-screen" style={{background: 'var(--background)'}}>
      <div className="container mx-auto px-4 py-16 max-w-2xl">
        <div className="mb-8 text-center">
          <h1 className="text-5xl font-bold mb-3 pb-2 border-b" style={{color: 'var(--foreground)', borderColor: 'var(--border)'}}>About</h1>
          <p className="text-xl mb-6" style={{color: 'var(--muted)'}}>
            Hi! I&apos;m Chandu, an independent comics creator, cartoonist, and illustrator from Central Ohio.
          </p>
          <p className="text-md mb-6" style={{color: 'var(--foreground)'}}>
            I love to tell emotionally resonant stories through the medium of comics, such as my YA series <span className='font-bold italic'>All Our Monsters</span>.
          </p>
          <p className="text-md mb-6" style={{color: 'var(--foreground)'}}>
            I also create minicomics and single-issue comics. My work has been featured in various anthologies and exhibitions, and I&apos;m always looking for new opportunities to collaborate and share my art with the world.
          </p>
          <p className="text-md mb-6" style={{color: 'var(--foreground)'}}>
            I update the site regularly with new content, so be sure to check back often!
          </p>
          <Link href="/" className="inline-block hover:underline text-sm font-medium" style={{color: 'var(--accent)'}}>&larr; Back to Home</Link>
        </div>
      </div>
    </main>
  )
}
