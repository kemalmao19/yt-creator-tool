@val @scope(("window", "document"))
external createElement: string => Dom.element = "createElement"

module App = {
  @react.component
  let make = () => {
    <div>
      <TitleCheck props={text: "Here is title checker"} />
    </div>
  }
}

let onMessageListener = port => {
  Console.log(port)
  let render = createElement("div")
  let root = ReactDOM.Client.createRoot(render)
  ReactDOM.Client.Root.render(root, <App />)
}

let port = Chrome.Runtime.connect({name: "yt-widget-content"})
Chrome.Runtime.Port.addListener(port, onMessageListener)
