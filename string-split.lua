-- 字符串分割
-- 防止有人覆盖 string 方法
local myString = {}
local tmpString = {}
for key, value in pairs(string) do
  tmpString[key] = value
end
tmpString.split = myString.split or function(str, d)
  if str == '' and d ~= '' then
    return { str }
  elseif str ~= '' and d == '' then
    local lst = {}
    for key = 1, tmpString.len(str) do
      table.insert(lst, tmpString.sub(str, key, 1))
    end
    return lst
  else
    local lst = {}
    local n = tmpString.len(str) --长度
    local start = 1
    while start <= n do
      local i = tmpString.find(str, d, start) -- find 'next' 0
      if i == nil then
        table.insert(lst, tmpString.sub(str, start, n))
        break
      end
      table.insert(lst, tmpString.sub(str, start, i - 1))
      if i == n then
        table.insert(lst, '')
        break
      end
      start = i + 1
    end
    return lst
  end
end
for key, value in pairs(tmpString) do
  string[key] = string[key] or value
end
return myString
