import type {Metadata} from 'next'

export const metadata: Metadata = {
  title: 'Data Collection Framework Report',
  description: 'Data Collection Framework report.',
}

export default function RootLayout({children}: Readonly<{children: React.ReactNode}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
