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
      <div
        className="relative w-full h-200 rounded-md overflow-hidden border"
        style={{background: 'var(--surface)', borderColor: 'var(--border)'}}
      >
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
      <div className="mt-3 flex items-center justify-between text-sm" style={{color: 'var(--muted)'}}>
        <button
          onClick={prev}
          aria-label="Previous image"
          className="image-gallery-nav-btn"
        >
          Prev
        </button>
        <div className="text-xs">{currentIndex + 1} / {images.length}</div>
        <button
          onClick={next}
          aria-label="Next image"
          className="image-gallery-nav-btn"
        >
          Next
        </button>
      </div>
    </div>
  )
}
