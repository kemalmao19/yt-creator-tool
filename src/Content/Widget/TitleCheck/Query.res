open Webapi.Dom

let pause = () => {
  Js.Promise2.make((~resolve, ~reject) => {
    let _wait = Js.Global.setTimeout(_ => resolve(None), 500)
  })
}

exception TestError(string)

let rec queryDomHelp = async (maybeAncestor, selector, n): promise<Dom.element> => {
  if n < 0 {
    Js.Promise2.reject(TestError("Not Found"))
  } else {
    let _wait = await pause()
    let maybeEl: option<
      Dom.element,
    > = maybeAncestor->Belt.Option.mapWithDefault(
      Document.querySelector(document, selector),
      dialog => {
        dialog->Element.querySelector(selector)
      },
    )
    switch maybeEl {
    | None => await queryDomHelp(maybeAncestor, selector, n - 1)
    | Some(el) => Js.Promise2.resolve(el)
    }
  }
}

let query = (maybeUploadDialog, _) => {
  let videoTitleElQuery =
    queryDomHelp(maybeUploadDialog, "ytcp-video-title", 5)->Js.Promise2.then(el => el)
  let videoTitleInputElQuery =
    queryDomHelp(maybeUploadDialog, "ytcp-social-suggestion-input", 5)->Js.Promise2.then(el => el)
  Js.Promise2.all([videoTitleElQuery, videoTitleInputElQuery])
}

let queryResult = domEl =>
  ReactQuery.useQuery({
    queryFn: query(domEl, _),
    queryKey: ["titlechecker"],
    refetchOnMount: ReactQuery.refetchOnMount(#bool(true)),
    refetchOnWindowFocus: ReactQuery.refetchOnWindowFocus(#bool(false)),
    staleTime: ReactQuery.time(#number(1)),
  })
