open Webapi.Dom
type prop = {text: string}
type model = Overlimit(float) | Underlimit(float)
// type config = {attributes: bool, childList: bool, subtree: bool}

let titleSelector = "ytcp-video-title"
let titleSelectorInput = "ytcp-social-suggestion-input"
let observerConfig = {
  "attributes": false,
  "childList": true,
  "subtree": true,
}

module TitleChecker = {
  @react.component
  let make = (~maybeUploadDialog: option<Dom.element>) => {
    let (state, setState) = React.useState(_ => Underlimit(0.0))
    let view = {
      let children = switch state {
      | Overlimit(len) => [View.Progress.view(len), <View />]
      | Underlimit(len) => [View.Progress.view(len)]
      }
      React.array(children)
    }

    let watcher = (mutationList, observer) => {
      let textBoxLen =
        mutationList
        ->Belt.Array.get(0)
        ->Belt.Option.map(mutation => {MutationRecord.target(mutation)})
        ->Belt.Option.map(el => {Node.innerText(el)})
        ->Belt.Option.mapWithDefault(0, text => {String.length(text)})
        ->Int.toFloat

      if textBoxLen > 60. {
        setState(_ => Overlimit(textBoxLen))
      } else {
        setState(_ => Underlimit(textBoxLen))
      }
    }

    let observer = MutationObserver.make(watcher)

    let queryResult = Query.queryResult(maybeUploadDialog)

    switch queryResult {
    | {isLoading: true} => "Loading..."->React.string
    | {data: Some([titleEl, titleInput]), isLoading: false, isError: false} => {
        let initialState = {
          let len: float = Int.toFloat(String.length(Element.innerText(titleInput)))
          Console.log(len)
          if len > 60. {
            Overlimit(len)
          } else {
            Underlimit(len)
          }
        }
        if initialState != state {
          setState(_ => initialState)
        }
        MutationObserver.observe(observer, titleInput, observerConfig)
        ReactDOM.createPortal(view, titleEl)
      }
    | _ => React.null
    }
  }
}

let client = ReactQuery.Provider.createClient()

@react.component
let make = (~maybeUploadDialog) => {
  <ReactQuery.Provider client>
    <TitleChecker maybeUploadDialog />
  </ReactQuery.Provider>
}
