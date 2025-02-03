-- FZF
-- Fast inputs
-- vim.g._find_cmd = "fd --type f --hidden --follow --exclude .git"
-- vim.g._grep_cmd = "rg --column --line-number --no-heading --color=always --smart-case"
-- vim.g.fzf_layout = { window = { width = 1, height = 1 } }
-- vim.keymap.set("n", "<leader>z", ":Files<CR>", { noremap = true, silent = true })
-- vim.keymap.set("n", "<leader>za", function()
--     local fzf_default_command = os.getenv("FZF_DEFAULT_COMMAND")
--     vim.loop.os_setenv("FZF_DEFAULT_COMMAND", vim.g._find_cmd .. " --no-ignore --exclude .git")
--     vim.cmd("Files")
--     if fzf_default_command then
--         vim.loop.os_setenv("FZF_DEFAULT_COMMAND", fzf_default_command)
--     else
--         vim.loop.os_unsetenv("FZF_DEFAULT_COMMAND")
--     end
-- end, { noremap = true, silent = true })

return {}
