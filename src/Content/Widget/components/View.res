@module external colors: 'a = "@mui/material/colors"

module Progress = {
  let view = (len: float) => {
    let w_ = len /. 60.0 *. 100.
    let w = Js.Math.min_float(w_, 100.)
    let width = Float.toString(w) ++ "%"
    let backgroundColor = if len > 60.0 {
      colors["red"]["500"]
    } else if len > 42.0 {
      colors["yellow"]["300"]
    } else {
      colors["green"]["300"]
    }
    <div style={ReactDOM.Style.make(~color=backgroundColor, ())}>
      <Ui.LinearProgress color="inherit" value=w variant="determinate" />
    </div>
  }
}

@react.component
let make = () => {
  <div
    id="TitleChecker.view"
    style={ReactDOM.Style.make(
      ~color="red",
      ~fontSize="12px",
      ~padding="0.2rem 1rem",
      ~textAlign="right",
      (),
    )}>
    {React.string("Your title is too long ...")}
  </div>
}
