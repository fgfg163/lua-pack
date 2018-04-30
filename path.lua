local path = {}
path.basename = function(thePath)
  thePath = string.gsub(thePath, '\\', '/')
  thePath = string.gsub(thePath, '//+', '/')
  local thePathArray = string.split(thePath, '/')
  local res = table.remove(thePathArray)
  return res
end
path.dirname = function(thePath)
  thePath = string.gsub(thePath, '\\', '/')
  thePath = string.gsub(thePath, '//+', '/')
  local thePathArray = string.split(thePath, '/')
  table.remove(thePathArray)
  return table.concat(thePathArray, '/')
end
path.extname = function()
end
path.join = function(...)
  local pathArray = { ... }
  local resultPathArray = {}
  for key = 1, #pathArray do
    if pathArray[key] ~= '' then
      if type(pathArray[key]) ~= 'string' then
        error('bad argument #' .. key .. ' to \'path.join\' (string expected, got ' .. type(pathArray[key]) .. ')', 2)
      end
      local thePath = string.gsub(pathArray[key], '\\', '/')
      thePath = string.gsub(thePath, '//+', '/')
      local thePathArray = string.split(thePath, '/')
      for key2 = 1, #thePathArray do
        local theName = thePathArray[key2]
        if theName == '' and #resultPathArray > 0 then
        elseif theName == '.' and #resultPathArray > 0 then
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '' then
          table.remove(resultPathArray)
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '.' then
          resultPathArray = { '..' }
        elseif theName == '..' and #resultPathArray > 0 then
          table.remove(resultPathArray)
        else
          table.insert(resultPathArray, theName)
        end
      end
    end
  end
  return table.concat(resultPathArray, '/')
end
path.relative = function()
end
path.resolve = function(...)
  local pathArray = { ... }
  local resultPathArray = {}
  for key = 1, #pathArray do
    if pathArray[key] ~= '' then
      local thePath = string.gsub(string.gsub(pathArray[key], '\\', '/'), '/$', '')
      thePath = string.gsub(thePath, '//+', '/')
      local thePathArray = string.split(thePath, '/')
      for key2 = 1, #thePathArray do
        local theName = thePathArray[key2]
        if theName == '' and key2 == 1 then
          resultPathArray = { '' }
        elseif theName == '.' and #resultPathArray > 0 then
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '' then
          table.remove(resultPathArray)
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '.' then
          resultPathArray = { '..' }
        elseif theName == '..' and #resultPathArray > 0 then
          table.remove(resultPathArray)
        else
          table.insert(resultPathArray, theName)
        end
      end
    end
  end
  return table.concat(resultPathArray, '/')
end
return path
