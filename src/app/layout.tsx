import type { Metadata } from "next";
import "./globals.css";
import Nav from "@/components/Nav";

const siteUrl = 'https://tennety.art'

export const metadata: Metadata = {
  title: {
    default: 'The Art of Chandu Tennety',
    template: '%s | Chandu Tennety',
  },
  description: 'Independent comic creator, cartoonist and illustrator',
  metadataBase: new URL(siteUrl),
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: siteUrl,
    siteName: 'The Art of Chandu Tennety',
    title: 'The Art of Chandu Tennety',
    description: 'Independent comic creator, cartoonist and illustrator',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'The Art of Chandu Tennety',
    description: 'Independent comic creator, cartoonist and illustrator',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var d=document.documentElement;var t=localStorage.getItem('theme');if(t==='dark'||(!t&&window.matchMedia('(prefers-color-scheme: dark)').matches)){d.classList.add('dark')}else{d.classList.remove('dark')}}catch(e){}})()`,
          }}
        />
      </head>
      <body
        className="antialiased"
      >
        <Nav />
        {children}
      </body>
    </html>
  );
}
