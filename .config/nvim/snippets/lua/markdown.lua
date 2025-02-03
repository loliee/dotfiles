-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local ls = require("luasnip")
local fmta = require("luasnip.extras.fmt").fmta
local visual_insert = require("plugins.extras.sniputils").visual_insert

local d = ls.dynamic_node
local i = ls.insert_node
local s = ls.snippet
local c = ls.choice_node
local sn = ls.snippet_node
local t = ls.text_node

return {
  s( -- code block
    { trig = "code block", dscr = "Add code block, supports i,v modes." },
    fmta(
      [[
        ```<>
        <>
        ```

        ]],
      {
        c(1, { sn(nil, { t("console"), i(1) }), sn(nil, { t("yaml") }), sn(nil, { t("json") }) }),
        d(2, visual_insert),
      }
    )
  ),

  s( -- Bold
    { trig = "bold", dscr = "Bold text, supports i,v modes." },
    fmta("**<>**", { d(1, visual_insert) })
  ),

  s( -- Italic
    { trig = "italic", dscr = "Italic text, supports i,v modes." },
    fmta("*<>*", { d(1, visual_insert) })
  ),

  s( -- Link
    {
      trig = "link",
      desc = "Create markdown link, , supports i,v modes.",
    },
    fmta([[[<>](<>)]], { d(1, visual_insert), i(2, { "text" }) })
  ),

  s( -- Image Link
    {
      trig = "image link",
      desc = "Create markdown image link, supports i,v modes.",
    },
    fmta([[![](<>)]], { d(1, visual_insert) })
  ),
}
