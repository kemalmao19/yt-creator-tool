import { defineConfig } from "vite";
const { react } = require("@vitejs/plugin-react");

const defaultConfig = {
  build: {
    emptyOutputDir: false,
    rollupOptions: {
      input: {
        popup: "src/popup/Popup.jsx",
      },
      output: {
        assetFileNames: (asset) => {
          switch (asset.name) {
            case "popup":
              return "/popup/[name][ext]";
            default:
              return "[name].[ext]";
          }
        },
        entryFileNames: (chuck) => {
          switch (chuck.name) {
            case "popup":
              return "popup/[name].js";
            default:
              return "[name].js";
          }
        },
      },
    },
  },
  plugins: [react],
};

export default defineConfig(() => defaultConfig);
