import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Génère .next/standalone : un serveur minimal (server.js) avec uniquement
  // les fichiers nécessaires en production. Utilisé par le Dockerfile.
  output: "standalone",
};

export default nextConfig;
