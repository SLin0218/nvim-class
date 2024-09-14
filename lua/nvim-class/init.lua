local get_current_file_path = function()
  local current_buffer_id = vim.api.nvim_get_current_buf()
  local current_file_path = vim.api.nvim_buf_get_name(current_buffer_id)
  return current_file_path
end

-- java -jar fernflower.jar -dgs=1 c:\Temp\binary\library.jar c:\Temp\binary\Boot.class c:\Temp\source\


print(get_current_file_path())
