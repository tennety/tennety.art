export interface PostFrontmatter {
  title: string
  date: string
  tags: string[]
  images: string[]
  thumb?: string
  'shop-link'?: string
  [key: string]: unknown
}

export interface Post {
  slug: string
  frontmatter: PostFrontmatter
  content: string
}

/** Lightweight post summary used by admin list */
export interface PostSummary {
  slug: string
  title: string
}
