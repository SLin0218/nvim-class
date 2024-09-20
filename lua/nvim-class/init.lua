local get_current_file_path = function()
  local current_buffer_id = vim.api.nvim_get_current_buf()
  local current_file_path = vim.api.nvim_buf_get_name(current_buffer_id)
  return current_file_path
end

-- java -jar fernflower.jar -dgs=1 c:\Temp\binary\library.jar c:\Temp\binary\Boot.class c:\Temp\source\

print(get_current_file_path())

local function decompile_class_file(file_path)
  return '12345'
end

vim.api.nvim_create_autocmd('BufReadPre', {
  pattern = '*.class',
  callback = function()
    local file_path = vim.fn.expand('%:p') -- 获取 .class 文件的路径
    local decompiled_content = decompile_class_file(file_path)
    vim.api.nvim_buf_set_lines(0, 0, -1, false, decompiled_content)
  end,
})
