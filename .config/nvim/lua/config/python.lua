local venv = os.getenv("VIRTUAL_ENV")
local python_path = vim.fn.system("pyenv which python"):gsub("%s+", "")
if venv then
  vim.g.python3_host_prog = venv .. "/bin/python"
end
vim.g.python3_host_prog = python_path
