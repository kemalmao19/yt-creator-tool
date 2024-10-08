open Webapi

type page = Details | Others
type msg = SetPage(page)
type model = {currentPage: page}

let observerConfig = {
  "attributes": false,
  "childList": true,
  "subtree": true,
}

let document = Dom.Window.document(Dom.window)
let dummy = Dom.Document.createElement(document, "div")

let update = (state: model, action: msg) =>
  switch action {
  | SetPage(thePage) => {...state, currentPage: thePage}
  }

let app = Dom.Document.querySelector(document, "title")->Belt.Option.map(title => {
  module App = {
    @react.component
    let make = () => {
      let initialState = {currentPage: Others}
      let (state, dispatch) = React.useReducer(update, initialState)

      let onMessageListener = port => {
        Console.log(port)
      }
      let port = Chrome.Runtime.connect({name: "yt-widget-content"})
      Chrome.Runtime.Port.addListener(port, onMessageListener)

      let titleElWatcher = (mutationList: array<Dom.MutationRecord.t>, observer) => {
        Console.log2("title Changed", mutationList)
        let title =
          mutationList
          ->Belt.Array.get(0)
          ->Belt.Option.map(Dom.MutationRecord.target)
          ->Belt.Option.mapWithDefault("", Dom.Node.textContent)

        let route = Js.String.split(" - ", title)
        Console.log2("route", route)

        switch route {
        | ["Video details", _] | ["Detail video", _] => dispatch(SetPage(Details))
        | _ => dispatch(SetPage(Others))
        }
      }

      React.useEffect0(() => {
        let titleObserver = Dom.MutationObserver.make(titleElWatcher)
        Dom.MutationObserver.observe(titleObserver, title, observerConfig)
        let cleanUp = () => {
          Dom.MutationObserver.disconnect(titleObserver)
        }
        Some(cleanUp)
      })

      let detailsPage = () => [<TitleCheck />]
      let widgets = switch state.currentPage {
      | Details => detailsPage()
      | _ => []
      }

      Console.log2("which widgets", widgets)
      React.array(widgets)
    }
  }
  let root = ReactDOM.Client.createRoot(dummy)
  ReactDOM.Client.Root.render(root, <App />)
})
