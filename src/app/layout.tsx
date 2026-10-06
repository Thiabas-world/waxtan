import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";

// Source Serif 4 auto-hébergée (police variable, sous-ensemble latin : couvre
// le français). Pas de dépendance à Google Fonts au build ni à l'exécution.
const sourceSerif = localFont({
  variable: "--font-source-serif",
  src: [
    { path: "./fonts/SourceSerif4-latin.woff2", weight: "200 900", style: "normal" },
    // L'italique n'existe qu'en 400 : le navigateur simule le gras, comme sur la maquette.
    { path: "./fonts/SourceSerif4-latin-italic.woff2", weight: "400", style: "italic" },
  ],
});

export const metadata: Metadata = {
  title: "Waxtan, ta voix, ton meilleur atout",
  description:
    "Coach IA de communication orale pour les Africains francophones : prépare tes entretiens et entraîne ton éloquence.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="fr" className={`${sourceSerif.variable} antialiased`}>
      <body>{children}</body>
    </html>
  );
}
