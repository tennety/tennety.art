'use client'

import type {PostSummary} from '@/types/post'

type PostSelectorProps = {
  posts: PostSummary[]
  selectedSlug: string | null
  onSelect: (slug: string | null) => void
}

export default function PostSelector({posts, selectedSlug, onSelect}: PostSelectorProps) {
  return (
    <div className="mb-6">
      <label className="block mb-2 font-medium">Edit Existing Post:</label>
      <select
        value={selectedSlug || ''}
        onChange={e => onSelect(e.target.value || null)}
        className="w-full mb-4 p-2 border rounded"
      >
        <option value="">-- New Post --</option>
        {posts.map(post => (
          <option key={post.slug} value={post.slug}>{post.title || post.slug}</option>
        ))}
      </select>
    </div>
  )
}
