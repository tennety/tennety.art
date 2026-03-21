'use client'

import {useState} from 'react'

type FrontmatterData = Record<string, unknown>

type FrontmatterEditorProps = {
  frontmatter: FrontmatterData
  setFrontmatter: (updater: (fm: FrontmatterData) => FrontmatterData) => void
}

function AddFrontmatterField({frontmatter, setFrontmatter}: FrontmatterEditorProps) {
  const [key, setKey] = useState('')
  const [value, setValue] = useState('')
  return (
    <form
      className="flex gap-2 items-center mb-4"
      onSubmit={e => {
        e.preventDefault()
        if (!key || key === 'title' || key in frontmatter) return
        setFrontmatter(fm => ({...fm, [key]: value}))
        setKey('')
        setValue('')
      }}
    >
      <input
        value={key}
        onChange={e => setKey(e.target.value)}
        placeholder="New field name"
        className="p-2 border rounded text-sm dark:bg-gray-700 dark:text-gray-100 min-w-[8rem]"
      />
      <input
        value={value}
        onChange={e => setValue(e.target.value)}
        placeholder="Value"
        className="p-2 border rounded text-sm dark:bg-gray-700 dark:text-gray-100 flex-1"
      />
      <button
        type="submit"
        className="px-3 py-1 bg-green-600 text-white rounded text-xs hover:bg-green-700"
        disabled={!key || key === 'title' || key in frontmatter}
      >Add</button>
    </form>
  )
}

export default function FrontmatterEditor({frontmatter, setFrontmatter}: FrontmatterEditorProps) {
  return (
    <>
      {Object.keys(frontmatter).filter(k => k !== 'title').map(key => (
        <div key={key} className="mb-2 flex gap-2 items-center">
          <label className="block text-sm font-medium mb-1 min-w-[6rem]">{key}</label>
          <input
            value={String(frontmatter[key] ?? '')}
            onChange={e => setFrontmatter(fm => ({...fm, [key]: e.target.value}))}
            className="flex-1 p-2 border rounded text-sm dark:bg-gray-700 dark:text-gray-100"
          />
          <button
            type="button"
            className="ml-2 text-xs text-red-500 hover:underline"
            onClick={() => setFrontmatter(fm => {
              const copy = {...fm}
              delete copy[key]
              return copy
            })}
          >Remove</button>
        </div>
      ))}
      <AddFrontmatterField frontmatter={frontmatter} setFrontmatter={setFrontmatter} />
    </>
  )
}
