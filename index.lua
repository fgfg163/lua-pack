require 'string-split'
local path = require 'path'
console = require 'console'
local program = require 'commander'

-- 获取参数
program.option('-e, --entry', 'main.lua')
program.option('-o, --output', 'main-min.lua')
program.option('-d, --debug', false)
program.parse(arg)
local loadedList = {}
local preloadList = {}

-- 检查 output 文件是否可写
do
  local outputFile, err = io.open(program.params.output, 'w')
  if err then
    console.log(err)
    if outputFile then
      outputFile:close()
    end
    os.exit()
  end
  outputFile:close()
end

-- The approach for embedding precompiled Lua files is different from
-- the normal way of pasting the source code, so this function detects
-- whether a file is a binary file (Lua bytecode starts with the `ESC`
-- character):
local function is_bytecode(path)
  local f, res = io.open(path, "rb"), false
  if f then
    res = f:read(1) == "\027"
    f:close()
  end
  return res
end


-- Read the whole contents of a file into memory without any
-- processing.
local function readfile(path, is_bin)
  local f = assert(io.open(path, is_bin and "rb" or "r"))
  local s = assert(f:read("*a"))
  f:close()
  return s
end


-- Lua files to be embedded into the resulting amalgamation are read
-- into memory in a single go, because under some circumstances (e.g.
-- binary chunks, shebang lines, `-d` command line flag) some
-- preprocessing/escaping is necessary. This function reads a whole
-- Lua file and returns the contents as a Lua string.
local function readluafile(path)
  local is_bin = is_bytecode(path)
  local s = readfile(path, is_bin)
  local shebang
  if not is_bin then
    -- Shebang lines are only supported by Lua at the very beginning
    -- of a source file, so they have to be removed before the source
    -- code can be embedded in the output.
    shebang = s:match("^(#![^\n]*)")
    s = s:gsub("^#[^\n]*", "")
  end
  return s, is_bin, shebang
end

-- Lua 5.1's `string.format("%q")` doesn't convert all control
-- characters to decimal escape sequences like the newer Lua versions
-- do. This might cause problems on some platforms (i.e. Windows) when
-- loading a Lua script (opened in text mode) that contains binary
-- code.
local function qformat(code)
  local s = ("%q"):format(code)
  return (s:gsub("(%c)(%d?)", function(c, d)
    if c ~= "\n" then
      return (d ~= "" and "\\%03d" or "\\%d"):format(c:byte()) .. d
    end
  end))
end


local function readFileToTable(file)
  local result = {}
  for i = 0, math.huge do
    local line = file:read('*line')
    table.insert(result, line)
    if line == nil then
      break
    end
  end
  return result
end

local entryFile, err = io.open(program.params.entry, 'r')
if err then
  console.log(err)
  if file then
    entryFile:close()
  end
  os.exit()
end
local entryData = entryFile:read('*all')
entryFile:close()

local preloadEntry = {
  path = program.params.entry,
  name = program.params.entry:gsub('%.lua', ''):gsub('^[^%w-_]*', ''),
}
table.insert(preloadList, preloadEntry)
preloadList[preloadEntry.name] = preloadEntry

while #preloadList > 0 do
  local preloadObj = preloadList[1]
  table.remove(preloadList, 1)
  local entryFile, err = io.open(preloadObj.path, 'r')
  if not err then
    console.log('build file: ' .. preloadObj.path)
    local codeSource, is_bin = readluafile(preloadObj.path)
    local requireSource = ''
    if preloadObj.path:match('^%./') or preloadObj.path:match('^%.%./') or preloadObj.path:match('^/') then
      requireSource = '\npackage.sourceCode = package.sourceCode or {}\npackage.sourceCode[' .. qformat(preloadObj.name) .. '] = { path = ' .. qformat(preloadObj.path) .. ', name = ' .. qformat(preloadObj.name) .. ', source = ' .. qformat(codeSource) .. ' }' .. '\n'
    else
      requireSource = '\npackage.preload["' .. preloadObj.name .. '"] = assert(load(' .. qformat(codeSource) .. ', "@" ..' .. qformat(preloadObj.path) .. '))' .. '\n'
    end
    preloadObj.sourceCode = requireSource
    table.insert(loadedList, preloadObj.sourceCode)

    local dirName = path.dirname(preloadObj.path)
    if not is_bin then
      -- 寻找文件require的内容
      for value in codeSource:gmatch('require%s*%(?["\']([%w-_%./\\]+)["\']%)?') do
        local subRequirePath = value
        if not value:match('%.lua$') then
          subRequirePath = value .. '.lua'
        end
        if subRequirePath:match('^%./') or subRequirePath:match('^%.%./') or subRequirePath:match('^/') then
          local subRequireAbsolutePath = path.resolve(dirName, subRequirePath)
          local obj = {
            path = subRequireAbsolutePath,
            name = subRequireAbsolutePath,
          }
          if not preloadList[obj.name] then
            table.insert(preloadList, obj)
            preloadList[obj.name] = obj
          end
        else
          local obj = {
            path = subRequirePath,
            name = subRequirePath:gsub('%.lua', ''),
          }
          if not preloadList[obj.name] then
            table.insert(preloadList, obj)
            preloadList[obj.name] = obj
          end
        end
      end
    end
  else
    console.log(err)
  end
  if entryFile then
    entryFile:close()
  end
end

local outputFile, err = io.open(program.params.output, 'w')
if err then
  console.log(err)
  if outputFile then
    outputFile:close()
  end
  os.exit()
end

for k = #loadedList, 1, -1 do
  local v = loadedList[k]
  outputFile:write(v)
  outputFile:write('\n')
end
outputFile:write('\nrequire("' .. preloadEntry.name .. '")\n')
outputFile:close()
