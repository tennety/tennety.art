# tennety.art v3 — Illustration Portfolio

A modern, fast static site generator for showcasing illustration work. Features a local WYSIWYG editor, markdown-based content, and automatic static site generation with Netlify deployment.

## Technologies

- **Framework**: NextJS 16 (App Router)
- **Styling**: Tailwind CSS v4
- **Editor**: TipTap (WYSIWYG) with image uploads
- **Markdown**: gray-matter + remark
- **Deployment**: Netlify (static export)
- **Language**: TypeScript

## Setup

### Prerequisites
- Node.js 18+ and npm

### Installation

```bash
npm install
```

## Development

Start the local development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### Routes

- **`/`** — Home page with all posts
- **`/[slug]`** — Individual post pages
- **`/admin`** — Local WYSIWYG editor

## Creating Posts

### Via Local Editor

1. Navigate to [`http://localhost:3000/admin`](http://localhost:3000/admin)
2. Enter a title
3. Use the toolbar to format content:
   - **B**/`I` — Bold/Italic
   - `H1`/`H2` — Headings
   - `•` List / `1.` List — Lists
   - `<>` — Code blocks
   - `🖼️ Image` — Upload images locally
4. Click **Publish Post** to save

Images are saved to `public/uploads/` and referenced in the markdown.

### Manual Markdown

Create a `.md` file in `content/posts/`:

```markdown
---
title: "My Illustration"
date: "2026-02-14"
---

# My Illustration

Content here...
```

## Building

Build the static site:

```bash
npm run build
```

Output is generated in the `out/` directory (ready for Netlify).

## Deployment

### Netlify

1. **Push to GitHub** and connect your repo to Netlify, or
2. **Direct Deploy**: Copy the `out/` directory contents to a web host

The `netlify.toml` file is pre-configured:
- Build command: `npm run build`
- Publish directory: `out`

### Manual Static Hosting

The `out/` directory contains a fully static site with no server required. Upload to:
- Vercel
- GitHub Pages
- AWS S3
- Any static host

## File Structure

```
src/
├── app/
│   ├── (public)/
│   │   └── page.tsx          # Home page
│   ├── [slug]/
│   │   └── page.tsx          # Post detail pages
│   ├── admin/
│   │   └── page.tsx          # Editor UI
│   ├── api/
│   │   ├── save/             # Save posts endpoint
│   │   └── upload/           # Image upload endpoint
│   ├── layout.tsx
│   └── globals.css
├── components/
│   └── EditorToolbar.tsx      # TipTap toolbar
├── lib/
│   └── markdown.ts           # Post processing utilities
└── types/
    └── turndown.d.ts         # Type declarations
content/
├── posts/
    └── example.md            # Example post
public/
├── uploads/                  # User-uploaded images
```

## Customization

### Styling

The site uses Tailwind CSS v4 with full prose support for rendered markdown. Edit `src/app/globals.css` for custom styles.

### Editor Features

Modify `src/components/EditorToolbar.tsx` to add/remove editor features. Available TipTap extensions:
- `@tiptap/extension-image` — Images
- `@tiptap/extension-link` — Links
- `@tiptap/starter-kit` — Base formatting

### Post Metadata

Modify frontmatter in posts to add custom fields (e.g., tags, featured image, etc.). Update `src/lib/markdown.ts` to parse new fields.

## Troubleshooting

**SSR Hydration Errors**: Already handled with `immediatelyRender: false` on the TipTap editor.

**Images Not Showing**: Check `public/uploads/` directory exists and images were saved there.

**Build Fails**: Ensure `content/posts/` and `public/uploads/` directories exist.

## License

MIT
