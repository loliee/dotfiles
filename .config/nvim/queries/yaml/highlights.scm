; extends

["{" "}"] @punctuation.brace

; #ytt-marker! comes from lua/plugins/treesitter.lua: without it, the whole query is rejected
((comment) @ytt.marker
 (#lua-match? @ytt.marker "^#@")
 (#ytt-marker! @ytt.marker))
