return { -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  priority = 1000,
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  config = function()
    require("nvim-treesitter").install({
      "awk",
      "bash",
      "c",
      "cmake",
      "css",
      "csv",
      "diff",
      "dockerfile",
      "fish",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gotmpl",
      "gpg",
      "hcl",
      "helm",
      "html",
      "http",
      "javascript",
      "jinja",
      "jinja_inline",
      "jq",
      "json",
      "just",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "mermaid",
      "passwd",
      "perl",
      "php",
      "printf",
      "promql",
      "python",
      "query",
      "regex",
      "requirements",
      "rst",
      "ruby",
      "rust",
      "sql",
      "ssh_config",
      "starlark",
      "strace",
      "toml",
      "twig",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    })

    -- For queries/yaml/highlights.scm: #offset! moves a capture's ends, it cannot cut it down to the #@ of ytt
    vim.treesitter.query.add_directive("ytt-marker!", function(match, _, _, pred, metadata)
      local id = pred[2]
      local row, col = match[id][1]:start()
      metadata[id] = vim.tbl_extend("force", metadata[id] or {}, { range = { row, col, row, col + 2 } })
    end, { force = true })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local buf = args.buf
        local ft = args.match
        local lang = vim.treesitter.language.get_lang(ft) or ft

        if not pcall(vim.treesitter.start, buf, lang) then
          return
        end

        if ft ~= "ruby" then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end

        if ft == "ruby" then
          vim.bo[buf].syntax = "on"
        end
      end,
    })
  end,
}
