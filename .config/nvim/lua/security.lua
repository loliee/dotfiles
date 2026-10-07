local M = {}

-- Asked once per project and session; vim.secure keeps allow and deny in ~/.local/state/nvim/trust
local decided = {}

--- Whether the project holding a buffer or path may run its own code: build scripts, configs written in a language
---@param source integer|string buffer number, file or directory path
---@return boolean
function M.trusted(source)
  local name = type(source) == "number" and vim.api.nvim_buf_get_name(source) or source
  if name == "" then
    return false
  end
  -- Resolved: a file reached through a stow link belongs to its repository; a new file has no realpath yet
  local dir = vim.uv.fs_realpath(vim.fs.dirname(name))
  local path = vim.uv.fs_realpath(name) or (dir and vim.fs.joinpath(dir, vim.fs.basename(name)))
  if not path then
    return false
  end
  local root = vim.fs.root(path, ".git") or (vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path))
  if decided[root] == nil then
    decided[root] = vim.secure.read(root) == true
  end
  return decided[root]
end

return M
