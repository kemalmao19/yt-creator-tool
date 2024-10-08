open Webapi.Dom

type prop = {text: string}
type model = Overlimit(float) | Underlimit(float)

let titleSelector = "ytcp-video-title"
let titleSelectorInput = "ytcp-social-suggestion-input"
let observerConfig = {
  "attributes": false,
  "childList": true,
  "subtree": true,
}

let pause = () => {
  Js.Promise2.make((~resolve, ~reject) => {
    let wait = Js.Global.setTimeout(_ => resolve(None), 500)
  })
}

exception TestError(string)

let rec queryDomHelp = async (selector, n): promise<Dom.element> => {
  if n < 0 {
    Js.Promise2.reject(TestError("Not Found"))
  } else {
    let wait = await pause()
    let maybeEl: option<Dom.element> = Document.querySelector(document, selector)
    switch maybeEl {
    | None => await queryDomHelp(selector, n - 1)
    | Some(el) => Js.Promise2.resolve(el)
    }
  }
}

let query = _ => {
  let videoTitleElQuery = queryDomHelp("ytcp-video-title", 5)->Js.Promise2.then(el => el)
  let videoTitleInputElQuery =
    queryDomHelp("ytcp-social-suggestion-input", 5)->Js.Promise2.then(el => el)
  Js.Promise2.all([videoTitleElQuery, videoTitleInputElQuery])
}

module TitleChecker = {
  @react.component
  let make = () => {
    // let someTitleEl = Document.querySelector(document, titleSelector)
    // let someTitleInput =
    //   someTitleEl->Belt.Option.flatMap(el => Element.querySelector(el, titleSelectorInput))

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

    let queryResult = ReactQuery.useQuery({
      queryFn: query,
      queryKey: ["titlechecker"],
      refetchOnMount: ReactQuery.refetchOnMount(#bool(true)),
      refetchOnWindowFocus: ReactQuery.refetchOnWindowFocus(#bool(false)),
      staleTime: ReactQuery.time(#number(1)),
    })

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
    }
  }
}

let client = ReactQuery.Provider.createClient()

@react.component
let make = () => {
  <ReactQuery.Provider client>
    <TitleChecker />
  </ReactQuery.Provider>
}
