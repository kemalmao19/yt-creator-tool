import { createRoot } from "react-dom/client";
const port = chrome.runtime.connect({ name: "yt-widget-popup" });
const root = createRoot(document.getElementById("app"));

const Popup = () => {
  return (
    <div>
      <button style={{ cursor: "pointer" }} onClick={handleClick}>
        Turn on widget
      </button>
    </div>
  );
};

root.render(<Popup />);

function handleClick() {
  port.postMessage({ payload: "load-title-checker" });
}
