@val @scope(("window", "document"))
external createElement: string => Dom.element = "createElement"

module App = {
  @react.component
  let make = () => {
    Console.log("hello kemal")
    <> {React.string("Hello")} </>
  }
}

let render = createElement("div")
let root = ReactDOM.Client.createRoot(render)
ReactDOM.Client.Root.render(root, <App />)
