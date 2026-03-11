'use client'

import {useState} from 'react'
import {useRouter, useSearchParams} from 'next/navigation'
import {FunnelIcon as FunnelOutline, XMarkIcon} from '@heroicons/react/24/outline'
import {FunnelIcon as FunnelSolid} from '@heroicons/react/24/solid'
import type {Post} from '@/types/post'
import PostTile from '@/components/PostTile'

type FilterableGridProps = {
  posts: Post[]
  allTags: string[]
}

export default function FilterableGrid({posts, allTags}: FilterableGridProps) {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [filterOpen, setFilterOpen] = useState(() => {
    return searchParams.get('tags') !== null
  })

  const selectedTags = searchParams.get('tags')?.split(',').filter(Boolean) ?? []

  const setSelectedTags = (tags: string[]) => {
    const params = new URLSearchParams(searchParams.toString())
    if (tags.length === 0) {
      params.delete('tags')
    } else {
      params.set('tags', tags.join(','))
    }
    const qs = params.toString()
    router.replace(qs ? `?${qs}` : '/', {scroll: false})
  }

  const toggleTag = (tag: string) => {
    if (selectedTags.includes(tag)) {
      setSelectedTags(selectedTags.filter(t => t !== tag))
    } else {
      setSelectedTags([...selectedTags, tag])
    }
  }

  const filteredPosts = selectedTags.length === 0
    ? posts
    : posts.filter(post => {
        const postTags = Array.isArray(post.frontmatter.tags) ? post.frontmatter.tags : []
        return selectedTags.some(tag => postTags.includes(tag))
      })

  const pairs = filteredPosts.reduce<Post[][]>((acc, post, i) => {
    if (i % 2 === 0) acc.push([post])
    else acc[acc.length - 1].push(post)
    return acc
  }, [])

  return (
    <>
      <div className="flex items-center justify-end gap-3 mb-4">
        <button
          onClick={() => setFilterOpen(!filterOpen)}
          className="inline-flex items-center gap-1.5 px-3 py-1.5 text-sm font-medium rounded-md bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-200 hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
        >
          {selectedTags.length > 0 ? <FunnelSolid className="w-4 h-4" /> : <FunnelOutline className="w-4 h-4" />}
          Filter
          {selectedTags.length > 0 && (
            <span className="ml-1 px-1.5 py-0.5 text-xs bg-blue-500 text-white rounded-full">{selectedTags.length}</span>
          )}
        </button>
        {selectedTags.length > 0 && (
          <button
            onClick={() => setSelectedTags([])}
            className="text-sm text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
          >
            Clear all
          </button>
        )}
      </div>

      {filterOpen && (
        <div className="flex flex-wrap justify-end gap-2 mb-6">
          {allTags.map(tag => {
            const isSelected = selectedTags.includes(tag)
            return (
              <button
                key={tag}
                onClick={() => toggleTag(tag)}
                className={`inline-flex items-center gap-1 px-3 py-1 text-sm rounded-full border transition-colors ${
                  isSelected
                    ? 'bg-blue-500 text-white border-blue-500'
                    : 'bg-white dark:bg-gray-800 text-gray-700 dark:text-gray-300 border-gray-300 dark:border-gray-600 hover:border-blue-400 dark:hover:border-blue-400'
                }`}
              >
                {tag}
                {isSelected && <XMarkIcon className="w-3.5 h-3.5" />}
              </button>
            )
          })}
        </div>
      )}

      {filteredPosts.length === 0 ? (
        <p className="text-center text-gray-500 dark:text-gray-400 py-12">No posts match the selected tags.</p>
      ) : (
        <div className="flex flex-col gap-4">
          {pairs.map((pair, rowIdx) => (
            <div
              key={rowIdx}
              className={`grid gap-4 ${rowIdx % 2 === 0 ? 'grid-cols-[1.6fr_1fr]' : 'grid-cols-[1fr_1.6fr]'}`}
            >
              {pair.map((post: Post, tileIdx: number) => (
                <PostTile key={post.slug} post={post} isLarge={rowIdx % 2 === tileIdx % 2} />
              ))}
            </div>
          ))}
        </div>
      )}
    </>
  )
}
