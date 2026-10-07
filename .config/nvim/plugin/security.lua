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
