local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- The commit lazy-lock.json pins, as for every other plugin, not the tip of the branch
  local lock = vim.json.decode(table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
  local commit = lock["lazy.nvim"].commit
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--single-branch",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error == 0 then
    vim.fn.system({ "git", "-C", lazypath, "checkout", commit })
  end
  if vim.v.shell_error ~= 0 then
    -- Not left behind: the next start would take any lazypath as installed and pinned
    vim.fn.delete(lazypath, "rf")
    error("lazy.nvim: cannot clone and check out " .. commit)
  end
end
vim.opt.runtimepath:prepend(lazypath)

-- load lazy
require("lazy").setup("plugins", {
  install = {
    missing = false,
  },
  defaults = { lazy = true },
  ui = {
    border = "rounded",
  },
  debug = false,
  change_detection = {
    enabled = false,
    notify = false,
  },
})
