; extends

((comment) @injection.content
 (#lua-match? @injection.content "^#@")
 (#offset! @injection.content 0 2 0 0)
 (#set! injection.language "starlark"))

([
  (double_quote_scalar)
  (single_quote_scalar)
  (string_scalar)
  (block_scalar)
] @injection.content
 (#lua-match? @injection.content "{[{%%]")
 (#set! injection.language "jinja"))

; Ansible conditions are Jinja expressions without braces: jinja_inline reads them as errors, Python does not
(block_mapping_pair
 key: (flow_node) @_key
 (#any-of? @_key "when" "changed_when" "failed_when" "until")
 value: (flow_node
  (plain_scalar
   (string_scalar) @injection.content))
 (#set! injection.language "python"))

(block_mapping_pair
 key: (flow_node) @_key
 (#any-of? @_key "when" "changed_when" "failed_when" "until")
 value: (block_node
  (block_sequence
   (block_sequence_item
    (flow_node
     (plain_scalar
      (string_scalar) @injection.content)))))
 (#set! injection.language "python"))
