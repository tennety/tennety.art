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
]

export default function LinksPage() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-950">
      <div className="container mx-auto px-4 py-16 max-w-md">
        <div className="mb-8 text-center">
          <h1 className="text-5xl font-bold text-gray-900 dark:text-gray-50 mb-3 pb-2 border-b border-gray-300 dark:border-gray-600">Links</h1>
        </div>
        <ul className="flex flex-col gap-3">
          {links.map(link => (
            <li key={link.href}>
              <a
                href={link.href}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center justify-center gap-2 w-full px-4 py-3 text-center font-medium rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-50 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors no-underline"
              >
                {link.label}
                <ArrowTopRightOnSquareIcon className="w-4 h-4 text-gray-400" />
              </a>
            </li>
          ))}
        </ul>
      </div>
    </main>
  )
}
