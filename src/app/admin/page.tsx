'use client'

import {useState, useEffect, useCallback} from 'react'
import {useEditor, EditorContent} from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import TurndownService from 'turndown'
import {EditorToolbar} from '@/components/EditorToolbar'
import FrontmatterEditor from '@/components/FrontmatterEditor'
import PostSelector from '@/components/PostSelector'
import type {PostSummary} from '@/types/post'

type FrontmatterData = Record<string, unknown>

export default function AdminPage() {
  const [title, setTitle] = useState('')
  const [posts, setPosts] = useState<PostSummary[]>([])
  const [selectedSlug, setSelectedSlug] = useState<string | null>(null)
  const [frontmatter, setFrontmatter] = useState<FrontmatterData>({})
  const [status, setStatus] = useState<{type: 'idle' | 'saving' | 'error' | 'success', message?: string}>({type: 'idle'})

  const editor = useEditor({
    extensions: [
      StarterKit,
      Image.configure({
        allowBase64: true,
      }),
      Link.configure({
        openOnClick: false,
      }),
    ],
    content: '',
    immediatelyRender: false,
  })

  useEffect(() => {
    fetch('/api/posts')
      .then(res => {
        if (!res.ok) throw new Error('Failed to load posts')
        return res.json()
      })
      .then(data => setPosts(data.posts || []))
      .catch(() => setStatus({type: 'error', message: 'Failed to load posts list'}))
  }, [])

  useEffect(() => {
    if (!selectedSlug) return
    fetch(`/api/post/${selectedSlug}`)
      .then(res => {
        if (!res.ok) throw new Error('Failed to load post')
        return res.json()
      })
      .then(data => {
        setTitle(data.frontmatter.title || '')
        setFrontmatter(data.frontmatter || {})
        editor?.commands.setContent(data.content || '')
      })
      .catch(() => setStatus({type: 'error', message: `Failed to load post: ${selectedSlug}`}))
  }, [selectedSlug, editor])

  const savePost = useCallback(async () => {
    setStatus({type: 'saving'})
    try {
      const fm = {...frontmatter, title}
      const fmString =
        '---\n' +
        Object.entries(fm)
          .map(([k, v]) => `${k}: ${JSON.stringify(v)}`)
          .join('\n') +
        '\n---\n\n'
      const html = editor?.getHTML() ?? ''
      const turndown = new TurndownService()
      const markdownBody = turndown.turndown(html)
      const body = fmString + markdownBody
      const slug = selectedSlug || title.toLowerCase().replace(/[^a-z0-9]+/g, '-')
      const res = await fetch('/api/save', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({body, slug})
      })
      if (!res.ok) throw new Error('Save failed')
      setStatus({type: 'success', message: 'Post saved!'})
    } catch {
      setStatus({type: 'error', message: 'Failed to save post'})
    }
  }, [frontmatter, title, editor, selectedSlug])

  const clearEditor = useCallback(() => {
    setTitle('')
    setFrontmatter({})
    editor?.commands.clearContent()
    setSelectedSlug(null)
    setStatus({type: 'idle'})
  }, [editor])

  return (
    <main className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="container mx-auto px-4 py-12 max-w-3xl">
        <div className="mb-8 text-center">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-50 mb-2">Admin: Edit or Create Post</h1>
          <p className="text-gray-600 dark:text-gray-400">Select a post to edit, or create a new one.</p>
        </div>

        {status.type === 'error' && (
          <div className="mb-4 p-3 text-sm bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300 rounded-lg">
            {status.message}
          </div>
        )}
        {status.type === 'success' && (
          <div className="mb-4 p-3 text-sm bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 rounded-lg">
            {status.message}
          </div>
        )}

        <PostSelector posts={posts} selectedSlug={selectedSlug} onSelect={setSelectedSlug} />

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Post Title"
            className="w-full text-2xl font-semibold text-gray-900 dark:text-gray-50 dark:bg-gray-800 mb-4 pb-2 border-b-2 border-gray-300 dark:border-gray-600 focus:border-blue-500 dark:focus:border-blue-400 focus:outline-none transition-colors"
          />
          <FrontmatterEditor
            frontmatter={frontmatter}
            setFrontmatter={setFrontmatter}
          />
          <EditorToolbar editor={editor} />
          <div className="w-full min-h-80 mt-2 bg-gray-50 dark:bg-gray-900 rounded border border-gray-200 dark:border-gray-700 prose dark:prose-invert prose-sm prose-p:my-2">
            <EditorContent editor={editor} />
          </div>
          <div className="mt-6 flex gap-4">
            <button
              onClick={savePost}
              disabled={status.type === 'saving'}
              className="px-6 py-3 bg-blue-600 dark:bg-blue-700 text-white font-medium rounded-lg hover:bg-blue-700 dark:hover:bg-blue-600 transition-colors disabled:opacity-50"
            >
              {status.type === 'saving' ? 'Saving...' : 'Save Post'}
            </button>
            <button
              onClick={clearEditor}
              className="px-6 py-3 bg-gray-200 dark:bg-gray-700 text-gray-800 dark:text-gray-200 font-medium rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
            >
              Clear
            </button>
          </div>
        </div>
      </div>
    </main>
  )
}
