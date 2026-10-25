; extends

((comment) @injection.content
 (#lua-match? @injection.content "^#@")
 (#offset! @injection.content 0 2 0 0)
 (#set! injection.language "starlark"))
