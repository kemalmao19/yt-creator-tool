import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const defaultConfig = {
  build: {
    inlineDynamicImports: true,
    emptyOutDir: true, // runs first
    rollupOptions: {
      input: "src/Content/App.res.js",
      output: {
        assetFileNames: (asset) => {
          switch (asset.name) {
            case "content":
              return "/content/[name].[ext]";
            default:
              return "[name].[ext]";
          }
        },
        entryFileNames: (chunk) => {
          return "content/content.js";
        },
      },
    },
  },
  plugins: [react()],
};

export default defineConfig(defaultConfig);
