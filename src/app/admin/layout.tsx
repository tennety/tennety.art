import {notFound} from 'next/navigation'

export default function AdminLayout({children}: {children: React.ReactNode}) {
  if (process.env.NEXT_PUBLIC_ENABLE_ADMIN !== 'true') {
    notFound()
  }
  return <>{children}</>
}
