import './globals.css';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';

export const metadata = {
  title: 'MyVault — Your College, In Your Pocket',
  description:
    'The all-in-one student platform for B.Tech & Degree students. Study materials, exam results, placements, govt jobs, resume builder & more.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen flex flex-col bg-[#07080D] text-[#F0F4FF] antialiased">
        <Navbar />
        <main className="flex-1">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
