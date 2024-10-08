const listener = new Map();

chrome.runtime.onConnect.addListener((port) => {
  switch (port.name) {
    case "yt-widget-content": {
      listener.set(port.name, port);
      port.onMessage.addListener((msg) => {
        console.log("content listenning..", msg);
      });
    }
    case "yt-widget-popup": {
      listener.set(port.name, port);
      console.log("popup listening...");
      port.onMessage.addListener((msg) => {
        const contentPort = listener.get("yt-widget-content");
        if (contentPort) {
          contentPort.postMessage({
            tag: "init",
            payload: "TitleChecker",
          });
        }
      });
    }
  }
  port.onDisconnect.addListener(() => {
    listener.delete(port.name);
  });
});
