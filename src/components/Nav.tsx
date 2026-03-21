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
  {label: 'News', href: 'https://news.tennety.art', external: true},
]

export default function Nav() {
  const pathname = usePathname()

  return (
    <nav className="w-full backdrop-blur-sm border-b sticky top-0 z-40 border-border" style={{background: 'color-mix(in srgb, var(--background) 80%, transparent)'}}>
      <div className="container mx-auto max-w-6xl px-4 flex items-end justify-between min-h-12">
        <div className="flex items-end gap-6">
          <ul className="flex items-center pb-2 gap-6">
            {navItems.map(item => {
              const isActive = item.href === '/' ? pathname === '/' : pathname.startsWith(item.href)
              if (item.external) {
                return (
                  <li key={item.href}>
                    <a
                      href={item.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="nav-link nav-link-external"
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
                    className={`nav-link ${isActive ? 'nav-link-active' : ''}`}
                  >
                    {item.label}
                  </Link>
                </li>
              )
            })}
          </ul>
        </div>
        <ThemeToggle />
      </div>
    </nav>
  )
}
