-- ytt rejects a plain # comment in a template
if vim.fn.search([[\(^\|\s\)#@]], "nw") > 0 then
  vim.bo.commentstring = "#! %s"
  vim.b.ytt = true
end
