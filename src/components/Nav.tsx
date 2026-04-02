'use client'

import {useState, useEffect, useCallback} from 'react'
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

function NavLinks({pathname, onClick}: {pathname: string; onClick?: () => void}) {
  return (
    <>
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
                onClick={onClick}
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
              onClick={onClick}
            >
              {item.label}
            </Link>
          </li>
        )
      })}
    </>
  )
}

export default function Nav() {
  const pathname = usePathname()
  const [menuOpen, setMenuOpen] = useState(false)

  // Close menu on Escape
  useEffect(() => {
    if (!menuOpen) return
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setMenuOpen(false)
    }
    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [menuOpen])

  const closeMenu = useCallback(() => setMenuOpen(false), [])

  return (
    <nav className="w-full backdrop-blur-sm border-b sticky top-0 z-40 border-border" style={{background: 'color-mix(in srgb, var(--background) 80%, transparent)'}}>
      <div className="container mx-auto max-w-6xl px-4 flex items-end justify-between min-h-12">
        {/* Desktop nav links */}
        <div className="hidden sm:flex items-end gap-6">
          <ul className="flex items-center pb-2 gap-6">
            <NavLinks pathname={pathname} />
          </ul>
        </div>

        {/* Mobile hamburger button */}
        <button
          className="sm:hidden relative w-8 h-8 mb-2 hamburger-btn"
          onClick={() => setMenuOpen(prev => !prev)}
          aria-expanded={menuOpen}
          aria-label="Toggle navigation menu"
        >
          <span
            className={`absolute left-1/2 top-1/2 -translate-x-1/2 block w-5 h-0.5 bg-foreground transition-transform duration-300 ${
              menuOpen ? '-translate-y-1/2 rotate-45' : '-translate-y-[5px]'
            }`}
          />
          <span
            className={`absolute left-1/2 top-1/2 -translate-x-1/2 block w-5 h-0.5 bg-foreground transition-transform duration-300 ${
              menuOpen ? '-translate-y-1/2 -rotate-45' : 'translate-y-[3px]'
            }`}
          />
        </button>

        <ThemeToggle />
      </div>

      {/* Mobile menu panel */}
      {menuOpen && (
        <div className="sm:hidden border-t border-border">
          <ul className="container mx-auto max-w-6xl px-4 py-4 flex flex-col gap-4">
            <NavLinks pathname={pathname} onClick={closeMenu} />
          </ul>
        </div>
      )}
    </nav>
  )
}
