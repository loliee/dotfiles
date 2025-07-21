-- Filetype detection
vim.filetype.add({
  pattern = {
    [".*/ansible/.*%.ya?ml"] = "yaml.ansible",
  },
})

vim.filetype.add({
  pattern = {
    [".*docker%-compose.*.ya?ml"] = "yaml.docker-compose",
  },
})

vim.filetype.add({
  pattern = {
    ["%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
    [".*gitlab%-ci/.*.ya?ml"] = "yaml.gitlab",
  },
})

vim.filetype.add({
  pattern = {
    [".*justfile"] = "just",
    [".*Justfile"] = "just",
  },
})

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".*goss.*"] = "gotmpl",
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})
