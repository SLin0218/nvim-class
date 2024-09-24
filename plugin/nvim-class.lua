vim.api.nvim_create_autocmd('BufRead', {
  pattern = '*.class',
  callback = function()
    local file_path = vim.fn.expand('%:p')
    require('nvim-class').replace_buffer(file_path)
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local file_path = vim.fn.expand('%:p')
    if string.find(file_path, 'zipfile') == 1 then
      require('nvim-class').replace_buffer(file_path)
    end
  end,
})
