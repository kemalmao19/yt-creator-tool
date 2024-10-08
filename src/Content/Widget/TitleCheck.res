type prop = {text: string}
let titleSelector = "ytcp-video-title"

@react.component
let make = (~props: prop) => {
  let someTitleEl = ReactDOM.querySelector(titleSelector)
  let view = <div id="TitleChecker.view"> {React.string(props.text)} </div>

  someTitleEl->Belt.Option.mapWithDefault(<> </>, titleEl => {
    ReactDOM.createPortal(view, titleEl)
  })
}
