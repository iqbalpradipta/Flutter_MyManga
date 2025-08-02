import type { Metadata } from "next";
import "./globals.css";
import Sidebar from "./components/Sidebar";

export const metadata: Metadata = {
  title: "Dashboard",
  description: "MangaBal Dashboard overview",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>
        <div className="grid grid-cols-5 gap-3">
          <div className="col-span-1">
            <Sidebar />
          </div>
          <div className="col-span-4">{children}</div>
        </div>
      </body>
    </html>
  );
}
