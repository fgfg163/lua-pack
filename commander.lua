-- 处理输入参数
require 'string-split'

local commander = {
  keys = {},
  params = {},
}

local optionKey = {}

commander.option = function(key, defaultValue)
  key = key or ''
  if type(key) == 'table' then
  end
  local optionObj = {
    keys = {},
    key = defaultValue,
    defaultValue = defaultValue,
  }
  local keyArr = key:split(',')
  for k, v in ipairs(keyArr) do
    local theK = v:gsub('^%s*(.-)%s*$', '%1'):gsub('^-+', '')
    optionObj.key = theKey
    table.insert(optionObj.keys, theK)
  end
  for k, v in ipairs(optionObj.keys) do
    optionKey[v] = optionObj
  end
  for k, v in ipairs(optionObj.keys) do
    table.insert(commander.keys, v)
  end
  for k, v in ipairs(optionObj.keys) do
    if defaultValue ~= nil then
      commander.params[v] = defaultValue
    end
  end
  return commander
end

commander.parse = function(params)
  params = params or {}
  local i = 1
  local paramsLength = #params
  while i <= paramsLength do
    if type(params[i]) == 'string' then
      local theKey = params[i]:gsub('^%s*(.-)%s*$', '%1'):gsub('^-+', '')
      if params[i]:gmatch('^-') and optionKey[theKey] then
        local optionObj = optionKey[theKey]
        local theParam = params[i + 1] ~= nil and params[i + 1] or true
        for k, v in ipairs(optionObj.keys) do
          commander.params[v] = theParam
        end
        i = i + 1
      end
    end
    i = i + 1
  end
  return commander
end

return commander
