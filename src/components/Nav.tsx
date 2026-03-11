'use client'

import Link from 'next/link'
import {usePathname} from 'next/navigation'
import {ArrowTopRightOnSquareIcon} from '@heroicons/react/24/outline'
import ThemeToggle from '@/components/ThemeToggle'

const navItems = [
  {label: 'Home', href: '/'},
  {label: 'About', href: '/about'},
  {label: 'Links', href: '/links'},
  {label: 'Shop', href: 'https://ko-fi.com/tennetyart/shop', external: true},
]

export default function Nav() {
  const pathname = usePathname()

  return (
    <nav className="w-full bg-white/80 dark:bg-gray-900/80 backdrop-blur-sm border-b border-gray-200 dark:border-gray-700 sticky top-0 z-40">
      <div className="container mx-auto max-w-6xl px-4 flex items-center justify-between h-12">
        <ul className="flex items-center gap-6">
          {navItems.map(item => {
            const isActive = item.href === '/' ? pathname === '/' : pathname.startsWith(item.href)
            if (item.external) {
              return (
                <li key={item.href}>
                  <a
                    href={item.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="inline-flex items-center gap-1 text-md font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 transition-colors no-underline"
                  >
                    {item.label}
                    <ArrowTopRightOnSquareIcon className="w-4 h-4" />
                  </a>
                </li>
              )
            }
            return (
              <li key={item.href}>
                <Link
                  href={item.href}
                  className={`text-md transition-colors no-underline ${
                    isActive
                      ? 'font-bold text-gray-900 dark:text-gray-50'
                      : 'font-medium text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100'
                  }`}
                >
                  {item.label}
                </Link>
              </li>
            )
          })}
        </ul>
        <ThemeToggle />
      </div>
    </nav>
  )
}
