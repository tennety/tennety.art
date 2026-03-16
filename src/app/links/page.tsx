import Image from 'next/image'
import {ArrowTopRightOnSquareIcon} from '@heroicons/react/24/outline'
import type {Metadata} from 'next'

export const metadata: Metadata = {
  title: 'Links',
  description: 'Links to Chandu Tennety\'s shop, commissions, social media, and more.',
  openGraph: {
    title: 'Links — Chandu Tennety',
    description: 'Shop, commissions, social media, and more.',
  },
}

const links = [
  {label: 'WTF bird sticker', href: 'https://ko-fi.com/s/75c2e18f62'},
  {label: 'Read a free comic', href: 'https://ko-fi.com/album/The-Marionette-P5P0G3Z7F'},
  {label: 'Buy me a tea', href: 'https://ko-fi.com/tennetyart'},
  {label: 'Commission me', href: 'https://ko-fi.com/tennetyart/commissions'},
  {label: 'Shop', href: 'https://ko-fi.com/tennetyart/shop'},
  {label: 'Instagram', href: 'https://instagram.com/tennety.art'},
  {label: 'News', href: 'https://news.tennety.art'},
]

export default function LinksPage() {
  return (
    <main className="min-h-screen" style={{background: 'var(--background)'}}>
      <div className="container mx-auto px-4 py-12 max-w-md">
        <div className="mb-8 flex flex-col items-center">
          <div className="mascot-hero p-2 mb-4">
            <Image
              src="/images/Front.png"
              alt="A towhee bird on a branch saying Comics! Illustration!"
              width={180}
              height={255}
              priority
            />
          </div>
          <h1 className="text-5xl font-bold mb-3 pb-2 border-b" style={{color: 'var(--foreground)', borderColor: 'var(--border)'}}>Chandu Tennety</h1>
          <p className="text-md" style={{color: 'var(--muted)'}}>Comics &middot; Illustration</p>
        </div>
        <ul className="flex flex-col gap-3">
          {links.map(link => (
            <li key={link.href}>
              <a
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2 w-full px-4 py-3 text-center font-medium rounded-lg border transition-colors no-underline"
                style={{background: 'var(--surface)', borderColor: 'var(--border)', color: 'var(--foreground)'}}
                onMouseEnter={undefined}
              >
                {link.label}
                <ArrowTopRightOnSquareIcon className="w-4 h-4" style={{color: 'var(--muted)'}} />
              </a>
            </li>
          ))}
        </ul>
      </div>
    </main>
  )
}
