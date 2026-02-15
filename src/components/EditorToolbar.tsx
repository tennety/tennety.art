'use client'

import {Editor} from '@tiptap/react'
import {useRef} from 'react'

interface EditorToolbarProps {
  editor: Editor | null
}

export function EditorToolbar({editor}: EditorToolbarProps) {
  const fileInputRef = useRef<HTMLInputElement>(null)

  if (!editor) return null

  const handleImageUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    const formData = new FormData()
    formData.append('file', file)

    try {
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
      })
      const {url} = await response.json()
      editor.chain().focus().setImage({src: url}).run()
    } catch (error) {
      console.error('Upload failed:', error)
    }
  }

  return (
    <div className="flex gap-1 p-3 bg-white dark:bg-gray-700 border border-b-2 border-gray-200 dark:border-gray-600 rounded-t flex-wrap">
      <button
        onClick={() => editor.chain().focus().toggleBold().run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('bold')
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Bold"
      >
        <strong>B</strong>
      </button>
      <button
        onClick={() => editor.chain().focus().toggleItalic().run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('italic')
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Italic"
      >
        <em>I</em>
      </button>
      <div className="w-px bg-gray-300 dark:bg-gray-500" />
      <button
        onClick={() => editor.chain().focus().toggleHeading({level: 1}).run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('heading', {level: 1})
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Heading 1"
      >
        H1
      </button>
      <button
        onClick={() => editor.chain().focus().toggleHeading({level: 2}).run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('heading', {level: 2})
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Heading 2"
      >
        H2
      </button>
      <div className="w-px bg-gray-300 dark:bg-gray-500" />
      <button
        onClick={() => editor.chain().focus().toggleBulletList().run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('bulletList')
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Bullet List"
      >
        • List
      </button>
      <button
        onClick={() => editor.chain().focus().toggleOrderedList().run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('orderedList')
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Ordered List"
      >
        1.
      </button>
      <button
        onClick={() => editor.chain().focus().toggleCodeBlock().run()}
        className={`px-3 py-2 text-sm font-medium rounded transition-colors ${
          editor.isActive('codeBlock')
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500'
        }`}
        title="Code Block"
      >
        &lt;&gt;
      </button>
      <div className="w-px bg-gray-300 dark:bg-gray-500" />
      <button
        onClick={() => fileInputRef.current?.click()}
        className="px-3 py-2 text-sm font-medium bg-gray-100 dark:bg-gray-600 text-gray-700 dark:text-gray-200 hover:bg-gray-200 dark:hover:bg-gray-500 rounded transition-colors"
        title="Upload Image"
      >
        🖼️ Image
      </button>
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleImageUpload}
        className="hidden"
      />
    </div>
  )
}
