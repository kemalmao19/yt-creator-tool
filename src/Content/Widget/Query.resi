let pause: unit => promise<option<'a>>

let queryDomHelp: (option<Webapi.Dom.Element.t>, string, int) => promise<promise<Dom.element>>

let query: (option<Webapi.Dom.Element.t>, 'a) => promise<array<Dom.element>>

let queryResult: option<Webapi.Dom.Element.t> => ReactQuery.queryResult<'a, array<Dom.element>>
