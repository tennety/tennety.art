import Link from 'next/link'
import Image from 'next/image'
import type {Post} from '@/types/post'

type PostTileProps = {
  post: Post
  isLarge: boolean
}

export default function PostTile({post, isLarge}: PostTileProps) {
  const imageSrc = post.frontmatter.thumb ?? (post.frontmatter.images.length > 0 ? post.frontmatter.images[0] : null)

  return (
    <Link href={`/${post.slug}`} className={isLarge ? undefined : 'block h-full'}>
      <div className={`group relative rounded-lg shadow-sm hover:shadow-lg transition-all duration-300 border overflow-hidden cursor-pointer border-border bg-surface ${isLarge ? 'aspect-[4/3]' : 'h-full'}`}>
        {imageSrc ? (
          <Image
            src={imageSrc}
            alt={post.frontmatter.title || post.slug}
            fill
            sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
            className="object-cover transition-transform duration-300 group-hover:scale-110"
            unoptimized
          />
        ) : null}
        <div className="absolute inset-0 flex flex-col justify-end bg-gradient-to-t from-black/70 via-black/30 to-transparent p-5 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
          <h4 className="text-white text-lg font-semibold mb-1 drop-shadow transition-colors">
            {post.frontmatter.title}
          </h4>
          {post.frontmatter.tags.length > 0 && (
            <div className="flex flex-wrap gap-1 mb-1 overflow-hidden max-w-full whitespace-nowrap">
              {post.frontmatter.tags.map((tag: string, i: number) => (
                <span
                  key={tag + i}
                  className="inline-block text-white text-xs px-2 py-0.5 rounded-full truncate max-w-[7rem] bg-[rgba(139,58,42,0.85)]"
                  title={tag}
                >
                  {tag}
                </span>
              ))}
            </div>
          )}
        </div>
      </div>
    </Link>
  )
}
