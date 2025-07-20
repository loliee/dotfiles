return {
  -- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim", branch = "master" },
  },
  build = "make tiktoken",
  cmd = { "CopilotChat" },
  opts = {
    question_header = "## User ",
    answer_header = "## Copilot ",
    error_header = "## Error ",
    mappings = {
      -- Use tab for completion
      complete = {
        detail = "Use @<Tab> or /<Tab> for options.",
        insert = "<Tab>",
      },
      -- Close the chat
      close = {
        normal = "q",
        insert = "<C-c>",
      },
      -- Reset the chat buffer
      reset = {
        normal = "<C-x>",
        insert = "<C-x>",
      },
      -- Submit the prompt to Copilot
      submit_prompt = {
        normal = "<CR>",
        insert = "<C-CR>",
      },
      -- Accept the diff
      accept_diff = {
        normal = "<C-y>",
        insert = "<C-y>",
      },
      -- Show help
      show_help = {
        normal = "?",
      },
    },
  },
}
