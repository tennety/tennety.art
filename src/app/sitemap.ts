import {getPostSlugs} from '@/lib/markdown'
import type {MetadataRoute} from 'next'
import {SITE_URL} from '@/lib/constants'

export const dynamic = 'force-static'

const siteUrl = SITE_URL

export default function sitemap(): MetadataRoute.Sitemap {
  const slugs = getPostSlugs().map(f => f.replace(/\.md$/, ''))

  const postEntries = slugs.map(slug => ({
    url: `${siteUrl}/${slug}`,
    lastModified: new Date(),
  }))

  return [
    {url: siteUrl, lastModified: new Date()},
    {url: `${siteUrl}/about`, lastModified: new Date()},
    {url: `${siteUrl}/links`, lastModified: new Date()},
    ...postEntries,
  ]
}
