-- Filetype detection
vim.filetype.add({
  pattern = {
    [".*/ansible/.*%.ya?ml"] = "yaml.ansible",
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
