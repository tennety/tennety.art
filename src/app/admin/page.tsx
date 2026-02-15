'use client'

import {useState} from 'react'
import {useEditor, EditorContent} from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import Image from '@tiptap/extension-image'
import Link from '@tiptap/extension-link'
import TurndownService from 'turndown'
import {EditorToolbar} from '@/components/EditorToolbar'

export default function AdminPage() {
  const [title, setTitle] = useState('')

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

  const savePost = async () => {
    const frontmatter = `---\ntitle: "${title}"\ndate: "${new Date().toISOString().split('T')[0]}"\n---\n\n`
    const html = editor?.getHTML() ?? ''
    const turndown = new TurndownService()
    const markdownBody = turndown.turndown(html)
    const body = frontmatter + markdownBody

    await fetch('/api/save', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({body, slug: title.toLowerCase().replace(/[^a-z0-9]+/g, '-')})
    })
    alert('Saved')
  }

  return (
    <main className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="container mx-auto px-4 py-12 max-w-3xl">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-gray-50 mb-2">Create New Post</h1>
          <p className="text-gray-600 dark:text-gray-400">Write and publish your next illustration story</p>
        </div>
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Post Title"
            className="w-full text-2xl font-semibold text-gray-900 dark:text-gray-50 dark:bg-gray-800 mb-4 pb-2 border-b-2 border-gray-300 dark:border-gray-600 focus:border-blue-500 dark:focus:border-blue-400 focus:outline-none transition-colors"
          />
          <EditorToolbar editor={editor} />
          <div className="w-full min-h-80 mt-2 bg-gray-50 dark:bg-gray-900 rounded border border-gray-200 dark:border-gray-700 prose dark:prose-invert prose-sm prose-p:my-2">
            <EditorContent editor={editor} />
          </div>
          <div className="mt-6 flex gap-4">
            <button
              onClick={savePost}
              className="px-6 py-3 bg-blue-600 dark:bg-blue-700 text-white font-medium rounded-lg hover:bg-blue-700 dark:hover:bg-blue-600 transition-colors"
            >
              Publish Post
            </button>
            <button
              onClick={() => {
                setTitle('')
                editor?.commands.clearContent()
              }}
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
