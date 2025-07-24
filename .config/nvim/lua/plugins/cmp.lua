return {
  "saghen/blink.cmp",
  version = "1.*",
  dependencies = { "L3MON4D3/LuaSnip", version = "v2.*" },
  snippets = { preset = "luasnip" },

  opts = {
    keymap = {
      -- set to 'none' to disable the 'default' preset
      preset = "default",
      ["<C-f>"] = { "accept" },
      ["<Tab>"] = { "select_next" },
      ["<C-u>"] = { "scroll_documentation_up" },
      ["<C-d>"] = { "scroll_documentation_down" },
      ["<S-Tab>"] = { "select_prev" },
      ["<C-space>"] = {
        function(cmp)
          cmp.show({ providers = { "lsp", "snippets" } })
        end,
      },
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    cmdline = {
      keymap = { preset = "inherit" },
      completion = { menu = { auto_show = false } },
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
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
