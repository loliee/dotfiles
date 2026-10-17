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

-- Files that hold secrets, as autocmd patterns; the temporary folders hold the copies sudo -e edits
M.secret_paths = {
  "/Volumes/OPXRamDisk/*",
  "*/.env",
  "*/.env.*",
  "*.env",
  "*/.envrc*",
  "*/.ssh/*",
  "*/.aws/*",
  "*/.kube/*",
  "*/.gnupg/*",
  "*/.docker/*",
  "*/.config/containers/auth.json",
  "*/.config/gh/*",
  "*/.config/glab-cli/*",
  "*/.config/op/*",
  "*/.netrc",
  "*kubeconfig*",
  "*.tfvars",
  "*.tfstate",
  "*.tfstate.backup",
  "*.pem",
  "*.key",
  "*.p12",
  "*/secrets.yaml",
  "*/secrets.yml",
  "/tmp/*",
  "/private/tmp/*",
  "/private/var/folders/*",
}

--- Whether a file holds secrets, by its name or, for an opx link into the ramdisk, by its target
---@param name string file path
---@return boolean
function M.secret(name)
  local paths = { name, vim.uv.fs_realpath(name) }
  for _, pattern in ipairs(M.secret_paths) do
    local regex = vim.fn.glob2regpat(pattern)
    for _, path in ipairs(paths) do
      if vim.fn.match(path, regex) ~= -1 then
        return true
      end
    end
  end
  return false
end

--- Whether a text holds a secret, as betterleaks finds it; a failed scan counts as one
---@param text string
---@param on_result fun(leaks: boolean)
function M.leaks(text, on_result)
  -- From the state folder: a project's .gitleaks.toml or .gitleaksignore could turn rules off
  vim.system(
    { "betterleaks", "stdin", "--no-banner", "--log-level", "error" },
    { stdin = text, cwd = vim.fn.stdpath("state") },
    vim.schedule_wrap(function(result)
      on_result(result.code ~= 0)
    end)
  )
end

return M
