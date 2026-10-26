import './globals.css';
import type { ReactNode } from 'react';

export const metadata = { title: 'Planet-M Shop', description: 'Linens for your furniture' };

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-white text-slate-900">{children}</body>
    </html>
  );
}
