open Webapi

type page = Details | Others
type msg = SetPage(page) | SetDialog(Dom.Node.t) | RemoveDialog
type model = {currentPage: page, maybeUploadPage: option<Dom.Node.t>}

let observerConfig = {
  "attributes": true,
  "childList": true,
  "subtree": true,
}

let document = Dom.Window.document(Dom.window)
let dummy = Dom.Document.createElement(document, "div")

let update = (state: model, action: msg) =>
  switch action {
  | RemoveDialog => {...state, maybeUploadPage: None}
  | SetDialog(dialog) => {...state, maybeUploadPage: Some(dialog)}
  | SetPage(thePage) => {...state, currentPage: thePage}
  }

let app = Dom.Document.querySelector(document, "title")->Belt.Option.map(title => {
  let bodyEl =
    Dom.document
    ->Dom.Document.asHtmlDocument
    ->Belt.Option.flatMap(Dom.HtmlDocument.body)
    ->Belt.Option.getWithDefault(dummy)

  module App = {
    @react.component
    let make = () => {
      let pageTitle = title->Dom.Element.textContent
      let route = Js.String.split(" - ", pageTitle)
      let initialPage = switch route {
      | ["Video details", _] | ["Detail video", _] => Details
      | _ => Others
      }
      let initialState = {currentPage: initialPage, maybeUploadPage: None}
      let (state, dispatch) = React.useReducer(update, initialState)

      let onMessageListener = port => {
        Console.log(port)
      }
      let port = Chrome.Runtime.connect({name: "yt-widget-content"})
      Chrome.Runtime.Port.addListener(port, onMessageListener)

      let bodyElWatcher = (mutationList, observer) => {
        let dialog = mutationList->Belt.Array.forEach(mutation => {
          let hasRemoveDialog =
            Dom.MutationRecord.removedNodes(mutation)
            ->Dom.NodeList.toArray
            ->Js.Array2.some(
              el => {
                let name = el->Dom.Node.nodeName->Js.String.toLowerCase
                name === "ytcp-uploads-dialog"
              },
            )
          if hasRemoveDialog {
            dispatch(RemoveDialog)
          } else {
            let target = Dom.MutationRecord.target(mutation)
            let name = target->Dom.Node.nodeName->Js.String.toLocaleLowerCase->Some
            let attributeName = Dom.MutationRecord.attributeName(mutation)
            let attribute =
              target
              ->Dom.Element.ofNode
              ->Belt.Option.flatMap(node => node->Dom.Element.getAttribute("workflow-step"))

            switch (name, attributeName, attribute) {
            | (Some("ytcp-uploads-dialog"), Some("workflow-step"), Some("DETAILS")) =>
              dispatch(SetDialog(target))
            | _ => ()
            }
          }
        })
        Console.log2("dialog added", dialog)
      }

      let titleElWatcher = (mutationList: array<Dom.MutationRecord.t>, observer) => {
        Console.log2("title Changed", mutationList)
        let title =
          mutationList
          ->Belt.Array.get(0)
          ->Belt.Option.map(Dom.MutationRecord.target)
          ->Belt.Option.mapWithDefault("", Dom.Node.textContent)

        let route = Js.String.split(" - ", title)
        // Console.log2("route", route)

        switch route {
        | ["Video details", _] | ["Detail video", _] => dispatch(SetPage(Details))
        | _ => dispatch(SetPage(Others))
        }
      }

      React.useEffectOnEveryRender(() => {
        let bodyObserver = Dom.MutationObserver.make(bodyElWatcher)
        let titleObserver = Dom.MutationObserver.make(titleElWatcher)
        Dom.MutationObserver.observe(bodyObserver, bodyEl, observerConfig)
        Dom.MutationObserver.observe(
          titleObserver,
          title,
          {
            "attributes": false,
            "childList": true,
            "subtree": true,
          },
        )
        let cleanUp = () => {
          Dom.MutationObserver.disconnect(bodyObserver)
          Dom.MutationObserver.disconnect(titleObserver)
        }
        Some(cleanUp)
      })

      let detailsPage = () => [<TitleCheck maybeUploadDialog=None key="details-page" />]
      let dialogWidget = dialog => [
        <TitleCheck maybeUploadDialog={Dom.Element.ofNode(dialog)} key="upload-dialog" />,
      ]
      let widgets = switch (state.currentPage, state.maybeUploadPage) {
      | (Details, None) => detailsPage()
      | (_, Some(dialog)) => dialogWidget(dialog)
      | _ => []
      }

      Console.log2("which widgets", widgets)
      React.array(widgets)
    }
  }
  let root = ReactDOM.Client.createRoot(dummy)
  ReactDOM.Client.Root.render(root, <App />)
})
