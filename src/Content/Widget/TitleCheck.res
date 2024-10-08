open Webapi.Dom

type prop = {text: string}

let titleSelector = "ytcp-video-title"
let observerConfig = {
  "attributes": false,
  "childList": true,
  "subtree": true,
}

@react.component
let make = (~props: prop) => {
  let someTitleEl = Document.querySelector(Webapi.Dom.document, titleSelector)
  let view = <div id="TitleChecker.view"> {React.string(props.text)} </div>

  let watcher = (mutationList, observer) => {
    let textBox =
      mutationList
      ->Belt.Array.get(0)
      ->Belt.Option.map(mutation => {MutationRecord.target(mutation)})
      ->Belt.Option.map(el => {Node.innerText(el)})
    Console.log(textBox)
  }

  let observer = MutationObserver.make(watcher)

  someTitleEl->Belt.Option.mapWithDefault(<> </>, titleEl => {
    MutationObserver.observe(observer, titleEl, observerConfig)
    // ReactDOM.createPortal(view, titleEl)
    <> </>
  })
}
