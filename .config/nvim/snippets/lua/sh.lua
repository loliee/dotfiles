-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md
local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmta = require("luasnip.extras.fmt").fmta

return {
  s({ -- Shebang
    trig = "#!",
    desc = "Add bash shebang.",
  }, {
    t({ "#!/usr/bin/env bash", "" }),
  }),

  s({ -- Debug statement
    trig = "debug",
    name = "debug",
    desc = "Add debug statement.",
  }, {
    t("[[ $DEBUG -eq 1 ]] && set -o xtrace"),
  }),

  s({ -- Trap statement
    trig = "trap",
    name = "trap",
    desc = "Add trap statement.",
  }, {
    t("trap "),
    i(1, "[function]"),
    t(" INT TERM HUP EXIT"),
  }),

  s({ -- Bash options short
    trig = "set+short",
    desc = "Add safe bash options, short version.",
  }, {
    t({ "set -euo pipefail", "" }),
  }),

  s({ -- Bash options long
    trig = "set+long",
    desc = "Add safe bash options, long version.",
  }, {
    t({ "set -o errexit", "set -o pipefail", "set -o nounset", "" }),
  }),

  s( -- Echo
    {
      trig = "echo >&2",
      desc = "Print message on stderr.",
    },
    fmta(
      [[
        echo >&2 "{}"

      ]],
      { i(1, { "[string]" }) },
      { delimiters = "{}" }
    )
  ),

  s( -- Cat
    {
      trig = "cat <<EOT",
      desc = "Write multi-string to file.",
    },
    fmta(
      [[
        cat <<EOT {}{}
        {}
        EOT

      ]],
      {
        c(1, { t(">"), t(">>") }),
        i(2, { "[file]" }),
        i(3, { "[content]" }),
      },
      { delimiters = "{}" }
    )
  ),
}
