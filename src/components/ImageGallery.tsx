"use client"
import {useCallback, useState} from 'react'
import Image from 'next/image'

type Props = {
  images: string[]
  alt?: string
}

export default function ImageGallery({images, alt}: Props) {
  const [index, setIndex] = useState(0)

  const prev = useCallback(() => setIndex(i => (i - 1 + images.length) % images.length), [images.length])
  const next = useCallback(() => setIndex(i => (i + 1) % images.length), [images.length])

  if (!images || images.length === 0) return null

  const currentIndex = index >= images.length ? 0 : index

  return (
    <div className="mb-8">
      <div className="relative w-full h-200 rounded-md overflow-hidden bg-gray-50 dark:bg-gray-800">
        <Image
          key={images.join(',')}
          src={images[currentIndex]}
          alt={alt ?? `Image ${currentIndex + 1}`}
          fill
          sizes="100vw"
          className="object-contain"
          unoptimized
        />
      </div>
      <div className="mt-3 flex items-center justify-between text-sm text-gray-600 dark:text-gray-400">
        <button onClick={prev} aria-label="Previous image" className="px-3 py-1 border rounded bg-white dark:bg-gray-800">Prev</button>
        <div className="text-xs">{currentIndex + 1} / {images.length}</div>
        <button onClick={next} aria-label="Next image" className="px-3 py-1 border rounded bg-white dark:bg-gray-800">Next</button>
      </div>
    </div>
  )
}
