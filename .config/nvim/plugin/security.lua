-- Secrets stay off the disk: no swap, undo or backup copy, and no shada to keep the session's registers
local security = require("security")
vim.opt.backupskip:append(security.secret_paths)
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("secrets-off-disk", { clear = true }),
  callback = function(args)
    if security.secret(args.match) then
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      -- backupskip matches the name as opened, not the target of an opx link into the ramdisk
      vim.opt.backupskip:append(vim.fn.escape(args.match, "\\,*?[{"))
      vim.o.shada = ""
    end
  end,
})

-- The undo file keeps what was deleted too, so a secret pasted then removed outlives the file's own content
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = vim.api.nvim_create_augroup("secrets-out-of-undo", { clear = true }),
  callback = function(args)
    if not vim.bo[args.buf].undofile then
      return
    end
    local path = vim.fn.undofile(vim.api.nvim_buf_get_name(args.buf))
    local file = io.open(path, "rb")
    if not file then
      return
    end
    local content = file:read("*a")
    file:close()
    security.leaks(content, function(leaks)
      if not leaks then
        return
      end
      os.remove(path)
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.bo[args.buf].undofile = false
      end
      vim.notify(
        "security: undo file with a secret deleted for " .. vim.fn.fnamemodify(args.match, ":~"),
        vim.log.levels.WARN
      )
    end)
  end,
})
