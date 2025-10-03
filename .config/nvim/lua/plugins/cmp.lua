local source_priority = {
  snippets = 40,
  copilot = 34,
  lsp = 30,
  path = 20,
  buffer = 10,
}

return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      config = function()
        require("luasnip.loaders.from_lua").lazy_load({ paths = { "~/.config/nvim/snippets/lua" } })
      end,
    },
    "giuxtaposition/blink-cmp-copilot",
  },
  opts = {
    keymap = {
      preset = "default",
      ["<C-f>"] = { "accept" },
      ["<C-u>"] = { "scroll_documentation_up" },
      ["<C-d>"] = { "scroll_documentation_down" },
      ["<C-n>"] = { "snippet_forward" },
      ["<C-p>"] = { "snippet_backward" },
      ["<C-space>"] = { "show" },
      ["<Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_next()
          end
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          end
        end,
        "fallback",
      },
    },
    snippets = {
      preset = "luasnip",
    },
    sources = {
      default = { "snippets", "lsp", "path", "buffer", "copilot" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    cmdline = {
      keymap = { preset = "inherit" },
      completion = { menu = { auto_show = true } },
    },
    completion = {
      menu = {
        auto_show = false,
        -- draw = {
        --   columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind" } },
        -- },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
    },
    fuzzy = {
      implementation = "prefer_rust_with_warning",
      -- Snippets first
      sorts = {
        function(a, b)
          local a_priority = source_priority[a.source_id]
          local b_priority = source_priority[b.source_id]
          if a_priority ~= b_priority then
            return a_priority > b_priority
          end
        end,
        -- defaults
        "score",
        "sort_text",
      },
    },
  },
}
