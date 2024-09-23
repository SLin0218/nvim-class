-- java -jar fernflower.jar -dgs=1 c:\Temp\binary\library.jar c:\Temp\binary\Boot.class c:\Temp\source\

local tmp = '/tmp/nvim-class/'

local function decompile_class_file(file_path)
  local jar = debug.getinfo(1, 'S').source:sub(2, -24) .. 'libs/fernflower.jar'
  local jcmd = vim.fn.glob('/Library/Java/JavaVirtualMachines/*17*/Contents/Home/bin/java')
  local end_index = string.find(string.reverse(file_path), '/')
  local sub_path = string.gsub(file_path:sub(2, -end_index - 1), '/', '.')
  local java_path = tmp .. sub_path
  if vim.fn.isdirectory(java_path) == 0 then
    os.execute('mkdir -p ' .. java_path)
  end

  if string.find(file_path, 'zipfile') == 1 then
    print(1)
  else
    -- 内部类 命名转义
    file_path = string.gsub(file_path, '%$', '\\$')
    local _ = io.popen(jcmd .. ' -jar ' .. jar .. ' ' .. file_path .. ' ' .. java_path):read("*a")
  end
  return vim.fn.readfile(java_path .. '/' .. vim.fn.expand('%:t'):sub(0, -7) .. '.java')
end
-- zipfile:///Users/a1/Workspace/fernflower/build/libs/fernflower.jar::org/jetbrains/java/decompiler/modules/decompiler/MergeHelper.class

local function replace_buffer(file_path)
  local buf = vim.api.nvim_get_current_buf()
  local decompiled_content = decompile_class_file(file_path)
  if vim.api.nvim_buf_get_option(buf, 'modifiable') then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, decompiled_content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  end
end

vim.api.nvim_create_autocmd('BufRead', {
  pattern = '*.class',
  callback = function()
    local file_path = vim.fn.expand('%:p')
    replace_buffer(file_path)
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local file_path = vim.fn.expand('%:p')
    if string.find(file_path, 'zipfile') == 1 then
      replace_buffer(file_path)
    end
  end,
})
