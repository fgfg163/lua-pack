require 'string-split'
local json = require 'json'
local path = require 'path'
console = require 'console'
local program = require 'commander'

program.option('-e, --entry', 'main.lua')
program.option('-o, --output', 'main-min.lua')
program.option('-sm, --source-code-mode', false)
program.parse(arg)
local loadedList = {}
local preloadList = {}

local outputFile, err = io.open(program.params.output, 'w')
if err then
  console.log(err)
  if outputFile then
    outputFile:close()
  end
  os.exit()
end
outputFile:close()

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
table.insert(preloadList, program.params.entry)
preloadList[program.params.entry] = program.params.entry

while #preloadList > 0 do
  local preloadPath = preloadList[1]
  local preloadPathName = preloadPath:gsub('.lua$', '')
  table.remove(preloadList, 1)
  local entryFile, err = io.open(preloadPath, 'r')
  if not err then
    console.log('build file: ' .. preloadPath)
    local requireTable = readFileToTable(entryFile)
    local requireSource = table.concat(requireTable, '\n')
    if program.params['source-code-mode'] then
      if type(program.params['source-code-mode']) == 'string' then
        requireSource = 'do\npackage[' .. json.encode(program['source-code-mode']) .. ']["' .. preloadPathName .. '"] = { path = "' .. preloadPath .. '", source = ' .. json.encode(requireSource) .. ' }' .. '\nend'
      else
        requireSource = 'do\npackage.sourceCode["' .. preloadPathName .. '"] = { path = "' .. preloadPath .. '", source = ' .. json.encode(requireSource) .. ' }' .. '\nend'
      end
    else
      requireSource = 'do\npackage.preload["' .. preloadPathName .. '"] = load(' .. json.encode(requireSource) .. ',"@' .. preloadPath .. '", "bt", _ENV)' .. '\nend'
    end
    table.insert(loadedList, requireSource)

    -- 寻找文件require的内容
    for k, v in ipairs(requireTable) do
      for value in v:gmatch('require%s*%(?["\']([%w-_./\\]+)["\']%)?') do
        local subRequirePath = value
        if not value:match('.lua$') then
          subRequirePath = subRequirePath .. '.lua'
        end
        if not preloadList[subRequirePath] then
          table.insert(preloadList, subRequirePath)
          preloadList[subRequirePath] = subRequirePath
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


if program.params['source-code-mode'] then
  if type(program.params['source-code-mode']) == 'string' then
    outputFile:write('do\npackage["' .. program.params['source-code-mode'] .. '"] = {}\nend\n')
  else
    outputFile:write('do\npackage.sourceCode = {}\nend\n')
  end
end
for k, v in ipairs(loadedList) do
  outputFile:write(v)
  outputFile:write('\n')
end
outputFile:write('\nrequire("' .. program.params.entry:gsub('.lua$', '') .. '")\n')
outputFile:close()
