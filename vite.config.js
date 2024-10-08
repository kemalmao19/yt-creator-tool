import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const defaultConfig = {
  build: {
    emptyOutDir: false,
    rollupOptions: {
      input: {
        popup: "src/Popup/Popup.jsx",
      },
      output: {
        assetFileNames: (asset) => {
          switch (asset.name) {
            case "popup":
              return "/popup/[name].[ext]";
            default:
              return "[name].[ext]";
          }
        },
        entryFileNames: (chunk) => {
          switch (chunk.name) {
            case "popup":
              return "popup/[name].js";

            default:
              return "[name].js";
          }
        },
      },
    },
  },

  plugins: [react()],
};

export default defineConfig(() => defaultConfig);
