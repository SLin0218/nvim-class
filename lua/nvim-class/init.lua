-- java -jar fernflower.jar -dgs=1 c:\Temp\binary\library.jar c:\Temp\binary\Boot.class c:\Temp\source\
local M = {}

local config = {
  cache_dir = '/tmp/nvim-class/',
}

local uv = (vim.uv or vim.loop)
local osname = uv.os_uname().sysname
if osname == 'Darwin' then
  config.java_cmd = vim.fn.glob('/Library/Java/JavaVirtualMachines/*17*/Contents/Home/bin/java')
elseif osname == 'Linux' then
  if uv.os_uname().release:find('arch') then
    config.java_cmd = vim.fn.glob('/usr/lib/jvm/*17*/bin/java')
  end
end

M.setup = function(args)
  args = args == nil and {} or args
  config = vim.tbl_deep_extend('force', config, args)
end

local function decompile_class_file(file_path)
  local jar = debug.getinfo(1, 'S').source:sub(2, -24) .. 'libs/fernflower.jar'
  local is_jar = string.find(file_path, 'zipfile') == 1
  local java_path = ''

  local sub_file = ''
  if is_jar then
    sub_file = file_path:sub(file_path:find('::') + 2, file_path:len())
    file_path = string.sub(file_path, 11, string.find(file_path, '::') - 1)
    java_path = config.cache_dir .. string.gsub(file_path:sub(2, -5), '/', '.')
  else
    local end_index = string.find(string.reverse(file_path), '/')
    local sub_path = string.gsub(file_path:sub(2, -end_index - 1), '/', '.')
    java_path = config.cache_dir .. sub_path
  end

  if vim.fn.isdirectory(java_path) == 0 then
    os.execute('mkdir -p ' .. java_path)
  end

  if is_jar then
    local decompile_jar = java_path .. '/' .. vim.fn.fnamemodify(file_path, ':t')
    if vim.fn.filereadable(decompile_jar) == 0 then
      -- decompilation and unzip
      local _ = io.popen(
        config.java_cmd
          .. ' -jar '
          .. jar
          .. ' '
          .. file_path
          .. ' '
          .. java_path
          .. ' && unzip '
          .. decompile_jar
          .. ' -d '
          .. java_path
      ):read('*a')
    end
    if sub_file:find('%$') then
      sub_file = sub_file:sub(0, sub_file:find('%$') - 1) .. '.java'
    else
      sub_file = sub_file:gsub('class$', 'java')
    end
    return vim.fn.readfile(java_path .. '/' .. sub_file)
  else
    -- 内部类 命名转义
    file_path = string.gsub(file_path, '%$', '\\$')
    local _ = io.popen(config.java_cmd .. ' -jar ' .. jar .. ' ' .. file_path .. ' ' .. java_path)
      :read('*a')
    return vim.fn.readfile(java_path .. '/' .. vim.fn.expand('%:t'):sub(0, -7) .. '.java')
  end
end
-- zipfile:///Users/a1/Workspace/fernflower/build/libs/fernflower.jar::org/jetbrains/java/decompiler/modules/decompiler/MergeHelper.class

M.replace_buffer = function(file_path)
  local buf = vim.api.nvim_get_current_buf()
  local decompiled_content = decompile_class_file(file_path)
  if vim.api.nvim_buf_get_option(buf, 'modifiable') then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, decompiled_content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  end
  -- vim.api.nvim_buf_set_option(buf, 'ft', 'java')
end

return M
