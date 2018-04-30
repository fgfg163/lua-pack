
package.preload["commander"] = assert(load("-- 处理输入参数\
require 'string-split'\
\
local commander = {\
  keys = {},\
  params = {},\
}\
\
local optionKey = {}\
\
commander.option = function(key, defaultValue)\
  key = key or ''\
  if type(key) == 'table' then\
  end\
  local optionObj = {\
    keys = {},\
    key = defaultValue,\
    defaultValue = defaultValue,\
  }\
  local keyArr = key:split(',')\
  for k, v in ipairs(keyArr) do\
    local theK = v:gsub('^%s*(.-)%s*$', '%1'):gsub('^-+', '')\
    optionObj.key = theKey\
    table.insert(optionObj.keys, theK)\
  end\
  for k, v in ipairs(optionObj.keys) do\
    optionKey[v] = optionObj\
  end\
  for k, v in ipairs(optionObj.keys) do\
    table.insert(commander.keys, v)\
  end\
  for k, v in ipairs(optionObj.keys) do\
    if defaultValue ~= nil then\
      commander.params[v] = defaultValue\
    end\
  end\
  return commander\
end\
\
commander.parse = function(params)\
  params = params or {}\
  local i = 1\
  local paramsLength = #params\
  while i <= paramsLength do\
    if type(params[i]) == 'string' then\
      local theKey = params[i]:gsub('^%s*(.-)%s*$', '%1'):gsub('^-+', '')\
      if params[i]:gmatch('^-') and optionKey[theKey] then\
        local optionObj = optionKey[theKey]\
        local theParam = params[i + 1] ~= nil and params[i + 1] or true\
        for k, v in ipairs(optionObj.keys) do\
          commander.params[v] = theParam\
        end\
        i = i + 1\
      end\
    end\
    i = i + 1\
  end\
  return commander\
end\
\
return commander\
", "@" .."commander.lua"))


package.preload["console"] = assert(load("local console = console or {}\
local __console = {}\
for key, value in pairs(console) do\
  __console[key] = value\
end\
\
\
local getLength = table.length or function(target)\
  local length = 0\
  for k, v in ipairs(target) do\
    length = k\
  end\
  return length\
end\
\
local isArray = table.isArray or function(tab)\
  if (type(tab) ~= \"table\") then\
    return false\
  end\
  local length = getLength(tab)\
  for k, v in pairs(tab) do\
    if ((type(k) ~= \"number\") or (k > length)) then\
      return false\
    end\
  end\
  return true\
end\
\
\
local function runTable(tab, space)\
  if type(tab) == 'number' then\
    return { tostring(tab) }\
  end\
  if type(tab) == 'string' then\
    if string.len(tab) > 1000 then\
      return { '\"' .. string.sub(tab, 1, 1000) .. '...\"' }\
    end\
    return { '\"' .. tab .. '\"' }\
  end\
  if type(tab) == 'boolean' then\
    if (tab) then\
      return { 'true' }\
    else\
      return { 'false' }\
    end\
  end\
  if type(tab) ~= 'table' then\
    return { '(' .. type(tab) .. ')' }\
  end\
  if type(space) == 'number' then\
    space = string.rep(' ', space)\
  end\
  if type(space) ~= 'string' then\
    space = ''\
  end\
\
  local resultStrList = {}\
  local newTabPairs = {}\
  local newTabPairsKeys = {}\
  local tabIsArray = true\
  local tabLength = 0\
  local hasSubTab = false\
\
  -- 将 table 的数组部分取出\
  for k, v in ipairs(tab) do\
    tabLength = k\
    table.insert(newTabPairs, { k, runTable(v, space) })\
    if (type(v) == 'table') then\
      hasSubTab = true\
    end\
  end\
\
  -- 将 table 的 map 部分取出，并按照字典顺序排序\
  for k, v in pairs(tab) do\
    if type(k) ~= 'number' or k > tabLength or k < 1 then\
      tabIsArray = false\
      table.insert(newTabPairsKeys, k)\
      if (type(v) == 'table') then\
        hasSubTab = true\
      end\
    end\
  end\
\
  table.sort(newTabPairsKeys)\
  for _, k in ipairs(newTabPairsKeys) do\
    table.insert(newTabPairs, { k, runTable(tab[k], space) })\
  end\
\
  if (tabIsArray) then\
    local newTabArr = newTabPairs\
\
    if (hasSubTab) then\
      table.insert(resultStrList, '[')\
      for k, v in ipairs(newTabArr) do\
        local v2Length = getLength(v[2])\
        v[2][v2Length] = v[2][v2Length] .. ','\
        for k2, v2 in ipairs(v[2]) do\
          table.insert(resultStrList, space .. v2)\
        end\
      end\
      table.insert(resultStrList, ']')\
    else\
      local theStr = {}\
      for k, v in ipairs(newTabPairs) do\
        table.insert(theStr, v[2][1])\
      end\
      local childStr = table.concat(theStr, ', ')\
      table.insert(resultStrList, '[' .. childStr .. ']')\
    end\
  else\
    local newTabArr = newTabPairs\
\
    table.insert(resultStrList, '{')\
    for k, v in ipairs(newTabArr) do\
      v[2][1] = v[1] .. ': ' .. v[2][1]\
      local v2Length = getLength(v[2])\
      v[2][v2Length] = v[2][v2Length] .. ','\
      for k2, v2 in ipairs(v[2]) do\
        table.insert(resultStrList, space .. v2 .. '')\
      end\
    end\
    table.insert(resultStrList, '}')\
  end\
  return resultStrList\
end\
\
\
__console.log = __console.log or function(obj)\
  local info = debug.getinfo(2, 'Sl')\
  local lineInfo = ''\
  if info.currentline then\
    lineInfo = info.source .. ': ' .. info.currentline .. ': '\
  end\
  local js = table.concat(runTable(obj, 2), \"\\n\")\
  print(lineInfo .. '\\n' .. js)\
  return js\
end\
\
__console.getJsStr = function(obj)\
  return table.concat(runTable(obj, 2), \",\\n\")\
end\
\
__console.color = function(value)\
  local resultStr = ''\
  local color = getColor(value[1], value[2])\
  local oldColor = value[3]\
  local colorStr = string.format('0x%06x', color)\
  local oldColorStr = string.format('0x%06x', oldColor)\
  value[3] = oldColorStr\
  if (color == oldColor) then\
    resultStr = resultStr .. '\\n' .. table.concat(runTable(value), \"\")\
  else\
    value[3] = colorStr\
    resultStr = resultStr .. '\\n' .. table.concat(runTable(value), \"\") .. '  old Color: ' .. oldColorStr\
  end\
  __console.log(resultStr)\
end\
\
for key, value in pairs(__console) do\
  console[key] = value\
end\
return console\
", "@" .."console.lua"))


package.preload["path"] = assert(load("local path = {}\
path.basename = function(thePath)\
  thePath = string.gsub(thePath, '\\\\', '/')\
  thePath = string.gsub(thePath, '//+', '/')\
  local thePathArray = string.split(thePath, '/')\
  local res = table.remove(thePathArray)\
  return res\
end\
path.dirname = function(thePath)\
  thePath = string.gsub(thePath, '\\\\', '/')\
  thePath = string.gsub(thePath, '//+', '/')\
  local thePathArray = string.split(thePath, '/')\
  table.remove(thePathArray)\
  return table.concat(thePathArray, '/')\
end\
path.extname = function()\
end\
path.join = function(...)\
  local pathArray = { ... }\
  local resultPathArray = {}\
  for key = 1, #pathArray do\
    if pathArray[key] ~= '' then\
      if type(pathArray[key]) ~= 'string' then\
        error('bad argument #' .. key .. ' to \\'path.join\\' (string expected, got ' .. type(pathArray[key]) .. ')', 2)\
      end\
      local thePath = string.gsub(pathArray[key], '\\\\', '/')\
      thePath = string.gsub(thePath, '//+', '/')\
      local thePathArray = string.split(thePath, '/')\
      for key2 = 1, #thePathArray do\
        local theName = thePathArray[key2]\
        if theName == '' and #resultPathArray > 0 then\
        elseif theName == '.' and #resultPathArray > 0 then\
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '' then\
          table.remove(resultPathArray)\
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '.' then\
          resultPathArray = { '..' }\
        elseif theName == '..' and #resultPathArray > 0 then\
          table.remove(resultPathArray)\
        else\
          table.insert(resultPathArray, theName)\
        end\
      end\
    end\
  end\
  return table.concat(resultPathArray, '/')\
end\
path.relative = function()\
end\
path.resolve = function(...)\
  local pathArray = { ... }\
  local resultPathArray = {}\
  for key = 1, #pathArray do\
    if pathArray[key] ~= '' then\
      local thePath = string.gsub(string.gsub(pathArray[key], '\\\\', '/'), '/$', '')\
      thePath = string.gsub(thePath, '//+', '/')\
      local thePathArray = string.split(thePath, '/')\
      for key2 = 1, #thePathArray do\
        local theName = thePathArray[key2]\
        if theName == '' and key2 == 1 then\
          resultPathArray = { '' }\
        elseif theName == '.' and #resultPathArray > 0 then\
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '' then\
          table.remove(resultPathArray)\
        elseif theName == '..' and #resultPathArray == 1 and resultPathArray[1] == '.' then\
          resultPathArray = { '..' }\
        elseif theName == '..' and #resultPathArray > 0 then\
          table.remove(resultPathArray)\
        else\
          table.insert(resultPathArray, theName)\
        end\
      end\
    end\
  end\
  return table.concat(resultPathArray, '/')\
end\
return path\
", "@" .."path.lua"))


package.preload["json"] = assert(load("--\
-- json.lua\
--\
-- Copyright (c) 2018 rxi\
--\
-- Permission is hereby granted, free of charge, to any person obtaining a copy of\
-- this software and associated documentation files (the \"Software\"), to deal in\
-- the Software without restriction, including without limitation the rights to\
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies\
-- of the Software, and to permit persons to whom the Software is furnished to do\
-- so, subject to the following conditions:\
--\
-- The above copyright notice and this permission notice shall be included in all\
-- copies or substantial portions of the Software.\
--\
-- THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE\
-- SOFTWARE.\
--\
\
local json = { _version = \"0.1.1\" }\
\
-------------------------------------------------------------------------------\
-- Encode\
-------------------------------------------------------------------------------\
\
local encode\
\
local escape_char_map = {\
  [ \"\\\\\" ] = \"\\\\\\\\\",\
  [ \"\\\"\" ] = \"\\\\\\\"\",\
  [ \"\\b\" ] = \"\\\\b\",\
  [ \"\\f\" ] = \"\\\\f\",\
  [ \"\\n\" ] = \"\\\\n\",\
  [ \"\\r\" ] = \"\\\\r\",\
  [ \"\\t\" ] = \"\\\\t\",\
}\
\
local escape_char_map_inv = { [ \"\\\\/\" ] = \"/\" }\
for k, v in pairs(escape_char_map) do\
  escape_char_map_inv[v] = k\
end\
\
\
local function escape_char(c)\
  return escape_char_map[c] or string.format(\"\\\\u%04x\", c:byte())\
end\
\
\
local function encode_nil(val)\
  return \"null\"\
end\
\
\
local function encode_table(val, stack)\
  local res = {}\
  stack = stack or {}\
\
  -- Circular reference?\
  if stack[val] then error(\"circular reference\") end\
\
  stack[val] = true\
\
  if val[1] ~= nil or next(val) == nil then\
    -- Treat as array -- check keys are valid and it is not sparse\
    local n = 0\
    for k in pairs(val) do\
      if type(k) ~= \"number\" then\
        error(\"invalid table: mixed or invalid key types\")\
      end\
      n = n + 1\
    end\
    if n ~= #val then\
      error(\"invalid table: sparse array\")\
    end\
    -- Encode\
    for i, v in ipairs(val) do\
      table.insert(res, encode(v, stack))\
    end\
    stack[val] = nil\
    return \"[\" .. table.concat(res, \",\") .. \"]\"\
\
  else\
    -- Treat as an object\
    for k, v in pairs(val) do\
      if type(k) ~= \"string\" then\
        error(\"invalid table: mixed or invalid key types\")\
      end\
      table.insert(res, encode(k, stack) .. \":\" .. encode(v, stack))\
    end\
    stack[val] = nil\
    return \"{\" .. table.concat(res, \",\") .. \"}\"\
  end\
end\
\
\
local function encode_string(val)\
  return '\"' .. val:gsub('[%z\\1-\\31\\\\\"]', escape_char) .. '\"'\
end\
\
\
local function encode_number(val)\
  -- Check for NaN, -inf and inf\
  if val ~= val or val <= -math.huge or val >= math.huge then\
    error(\"unexpected number value '\" .. tostring(val) .. \"'\")\
  end\
  return string.format(\"%.14g\", val)\
end\
\
\
local type_func_map = {\
  [ \"nil\"     ] = encode_nil,\
  [ \"table\"   ] = encode_table,\
  [ \"string\"  ] = encode_string,\
  [ \"number\"  ] = encode_number,\
  [ \"boolean\" ] = tostring,\
}\
\
\
encode = function(val, stack)\
  local t = type(val)\
  local f = type_func_map[t]\
  if f then\
    return f(val, stack)\
  end\
  error(\"unexpected type '\" .. t .. \"'\")\
end\
\
\
function json.encode(val)\
  return ( encode(val) )\
end\
\
\
-------------------------------------------------------------------------------\
-- Decode\
-------------------------------------------------------------------------------\
\
local parse\
\
local function create_set(...)\
  local res = {}\
  for i = 1, select(\"#\", ...) do\
    res[ select(i, ...) ] = true\
  end\
  return res\
end\
\
local space_chars   = create_set(\" \", \"\\t\", \"\\r\", \"\\n\")\
local delim_chars   = create_set(\" \", \"\\t\", \"\\r\", \"\\n\", \"]\", \"}\", \",\")\
local escape_chars  = create_set(\"\\\\\", \"/\", '\"', \"b\", \"f\", \"n\", \"r\", \"t\", \"u\")\
local literals      = create_set(\"true\", \"false\", \"null\")\
\
local literal_map = {\
  [ \"true\"  ] = true,\
  [ \"false\" ] = false,\
  [ \"null\"  ] = nil,\
}\
\
\
local function next_char(str, idx, set, negate)\
  for i = idx, #str do\
    if set[str:sub(i, i)] ~= negate then\
      return i\
    end\
  end\
  return #str + 1\
end\
\
\
local function decode_error(str, idx, msg)\
  local line_count = 1\
  local col_count = 1\
  for i = 1, idx - 1 do\
    col_count = col_count + 1\
    if str:sub(i, i) == \"\\n\" then\
      line_count = line_count + 1\
      col_count = 1\
    end\
  end\
  error( string.format(\"%s at line %d col %d\", msg, line_count, col_count) )\
end\
\
\
local function codepoint_to_utf8(n)\
  -- http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=iws-appendixa\
  local f = math.floor\
  if n <= 0x7f then\
    return string.char(n)\
  elseif n <= 0x7ff then\
    return string.char(f(n / 64) + 192, n % 64 + 128)\
  elseif n <= 0xffff then\
    return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)\
  elseif n <= 0x10ffff then\
    return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,\
                       f(n % 4096 / 64) + 128, n % 64 + 128)\
  end\
  error( string.format(\"invalid unicode codepoint '%x'\", n) )\
end\
\
\
local function parse_unicode_escape(s)\
  local n1 = tonumber( s:sub(3, 6),  16 )\
  local n2 = tonumber( s:sub(9, 12), 16 )\
  -- Surrogate pair?\
  if n2 then\
    return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)\
  else\
    return codepoint_to_utf8(n1)\
  end\
end\
\
\
local function parse_string(str, i)\
  local has_unicode_escape = false\
  local has_surrogate_escape = false\
  local has_escape = false\
  local last\
  for j = i + 1, #str do\
    local x = str:byte(j)\
\
    if x < 32 then\
      decode_error(str, j, \"control character in string\")\
    end\
\
    if last == 92 then -- \"\\\\\" (escape char)\
      if x == 117 then -- \"u\" (unicode escape sequence)\
        local hex = str:sub(j + 1, j + 5)\
        if not hex:find(\"%x%x%x%x\") then\
          decode_error(str, j, \"invalid unicode escape in string\")\
        end\
        if hex:find(\"^[dD][89aAbB]\") then\
          has_surrogate_escape = true\
        else\
          has_unicode_escape = true\
        end\
      else\
        local c = string.char(x)\
        if not escape_chars[c] then\
          decode_error(str, j, \"invalid escape char '\" .. c .. \"' in string\")\
        end\
        has_escape = true\
      end\
      last = nil\
\
    elseif x == 34 then -- '\"' (end of string)\
      local s = str:sub(i + 1, j - 1)\
      if has_surrogate_escape then\
        s = s:gsub(\"\\\\u[dD][89aAbB]..\\\\u....\", parse_unicode_escape)\
      end\
      if has_unicode_escape then\
        s = s:gsub(\"\\\\u....\", parse_unicode_escape)\
      end\
      if has_escape then\
        s = s:gsub(\"\\\\.\", escape_char_map_inv)\
      end\
      return s, j + 1\
\
    else\
      last = x\
    end\
  end\
  decode_error(str, i, \"expected closing quote for string\")\
end\
\
\
local function parse_number(str, i)\
  local x = next_char(str, i, delim_chars)\
  local s = str:sub(i, x - 1)\
  local n = tonumber(s)\
  if not n then\
    decode_error(str, i, \"invalid number '\" .. s .. \"'\")\
  end\
  return n, x\
end\
\
\
local function parse_literal(str, i)\
  local x = next_char(str, i, delim_chars)\
  local word = str:sub(i, x - 1)\
  if not literals[word] then\
    decode_error(str, i, \"invalid literal '\" .. word .. \"'\")\
  end\
  return literal_map[word], x\
end\
\
\
local function parse_array(str, i)\
  local res = {}\
  local n = 1\
  i = i + 1\
  while 1 do\
    local x\
    i = next_char(str, i, space_chars, true)\
    -- Empty / end of array?\
    if str:sub(i, i) == \"]\" then\
      i = i + 1\
      break\
    end\
    -- Read token\
    x, i = parse(str, i)\
    res[n] = x\
    n = n + 1\
    -- Next token\
    i = next_char(str, i, space_chars, true)\
    local chr = str:sub(i, i)\
    i = i + 1\
    if chr == \"]\" then break end\
    if chr ~= \",\" then decode_error(str, i, \"expected ']' or ','\") end\
  end\
  return res, i\
end\
\
\
local function parse_object(str, i)\
  local res = {}\
  i = i + 1\
  while 1 do\
    local key, val\
    i = next_char(str, i, space_chars, true)\
    -- Empty / end of object?\
    if str:sub(i, i) == \"}\" then\
      i = i + 1\
      break\
    end\
    -- Read key\
    if str:sub(i, i) ~= '\"' then\
      decode_error(str, i, \"expected string for key\")\
    end\
    key, i = parse(str, i)\
    -- Read ':' delimiter\
    i = next_char(str, i, space_chars, true)\
    if str:sub(i, i) ~= \":\" then\
      decode_error(str, i, \"expected ':' after key\")\
    end\
    i = next_char(str, i + 1, space_chars, true)\
    -- Read value\
    val, i = parse(str, i)\
    -- Set\
    res[key] = val\
    -- Next token\
    i = next_char(str, i, space_chars, true)\
    local chr = str:sub(i, i)\
    i = i + 1\
    if chr == \"}\" then break end\
    if chr ~= \",\" then decode_error(str, i, \"expected '}' or ','\") end\
  end\
  return res, i\
end\
\
\
local char_func_map = {\
  [ '\"' ] = parse_string,\
  [ \"0\" ] = parse_number,\
  [ \"1\" ] = parse_number,\
  [ \"2\" ] = parse_number,\
  [ \"3\" ] = parse_number,\
  [ \"4\" ] = parse_number,\
  [ \"5\" ] = parse_number,\
  [ \"6\" ] = parse_number,\
  [ \"7\" ] = parse_number,\
  [ \"8\" ] = parse_number,\
  [ \"9\" ] = parse_number,\
  [ \"-\" ] = parse_number,\
  [ \"t\" ] = parse_literal,\
  [ \"f\" ] = parse_literal,\
  [ \"n\" ] = parse_literal,\
  [ \"[\" ] = parse_array,\
  [ \"{\" ] = parse_object,\
}\
\
\
parse = function(str, idx)\
  local chr = str:sub(idx, idx)\
  local f = char_func_map[chr]\
  if f then\
    return f(str, idx)\
  end\
  decode_error(str, idx, \"unexpected character '\" .. chr .. \"'\")\
end\
\
\
function json.decode(str)\
  if type(str) ~= \"string\" then\
    error(\"expected argument of type string, got \" .. type(str))\
  end\
  local res, idx = parse(str, next_char(str, 1, space_chars, true))\
  idx = next_char(str, idx, space_chars, true)\
  if idx <= #str then\
    decode_error(str, idx, \"trailing garbage\")\
  end\
  return res\
end\
\
\
return json\
", "@" .."json.lua"))


package.preload["string-split"] = assert(load("-- 字符串分割\
-- 防止有人覆盖 string 方法\
local myString = {}\
local tmpString = {}\
for key, value in pairs(string) do\
  tmpString[key] = value\
end\
tmpString.split = myString.split or function(str, d)\
  if str == '' and d ~= '' then\
    return { str }\
  elseif str ~= '' and d == '' then\
    local lst = {}\
    for key = 1, tmpString.len(str) do\
      table.insert(lst, tmpString.sub(str, key, 1))\
    end\
    return lst\
  else\
    local lst = {}\
    local n = tmpString.len(str) --长度\
    local start = 1\
    while start <= n do\
      local i = tmpString.find(str, d, start) -- find 'next' 0\
      if i == nil then\
        table.insert(lst, tmpString.sub(str, start, n))\
        break\
      end\
      table.insert(lst, tmpString.sub(str, start, i - 1))\
      if i == n then\
        table.insert(lst, '')\
        break\
      end\
      start = i + 1\
    end\
    return lst\
  end\
end\
for key, value in pairs(tmpString) do\
  string[key] = string[key] or value\
end\
return myString\
", "@" .."string-split.lua"))


package.preload["index"] = assert(load("require 'string-split'\
local json = require 'json'\
local path = require 'path'\
console = require 'console'\
local program = require 'commander'\
\
program.option('-e, --entry', 'main.lua')\
program.option('-o, --output', 'main-min.lua')\
program.parse(arg)\
local loadedList = {}\
local preloadList = {}\
\
\
-- The approach for embedding precompiled Lua files is different from\
-- the normal way of pasting the source code, so this function detects\
-- whether a file is a binary file (Lua bytecode starts with the `ESC`\
-- character):\
local function is_bytecode(path)\
  local f, res = io.open(path, \"rb\"), false\
  if f then\
    res = f:read(1) == \"\\027\"\
    f:close()\
  end\
  return res\
end\
\
\
-- Read the whole contents of a file into memory without any\
-- processing.\
local function readfile(path, is_bin)\
  local f = assert(io.open(path, is_bin and \"rb\" or \"r\"))\
  local s = assert(f:read(\"*a\"))\
  f:close()\
  return s\
end\
\
\
-- Lua files to be embedded into the resulting amalgamation are read\
-- into memory in a single go, because under some circumstances (e.g.\
-- binary chunks, shebang lines, `-d` command line flag) some\
-- preprocessing/escaping is necessary. This function reads a whole\
-- Lua file and returns the contents as a Lua string.\
local function readluafile(path)\
  local is_bin = is_bytecode(path)\
  local s = readfile(path, is_bin)\
  local shebang\
  if not is_bin then\
    -- Shebang lines are only supported by Lua at the very beginning\
    -- of a source file, so they have to be removed before the source\
    -- code can be embedded in the output.\
    shebang = s:match(\"^(#![^\\n]*)\")\
    s = s:gsub(\"^#[^\\n]*\", \"\")\
  end\
  return s, is_bin, shebang\
end\
\
-- Lua 5.1's `string.format(\"%q\")` doesn't convert all control\
-- characters to decimal escape sequences like the newer Lua versions\
-- do. This might cause problems on some platforms (i.e. Windows) when\
-- loading a Lua script (opened in text mode) that contains binary\
-- code.\
local function qformat(code)\
  local s = (\"%q\"):format(code)\
  return (s:gsub(\"(%c)(%d?)\", function(c, d)\
    if c ~= \"\\n\" then\
      return (d ~= \"\" and \"\\\\%03d\" or \"\\\\%d\"):format(c:byte()) .. d\
    end\
  end))\
end\
\
local outputFile, err = io.open(program.params.output, 'w')\
if err then\
  console.log(err)\
  if outputFile then\
    outputFile:close()\
  end\
  os.exit()\
end\
outputFile:close()\
\
local function readFileToTable(file)\
  local result = {}\
  for i = 0, math.huge do\
    local line = file:read('*line')\
    table.insert(result, line)\
    if line == nil then\
      break\
    end\
  end\
  return result\
end\
\
local entryFile, err = io.open(program.params.entry, 'r')\
if err then\
  console.log(err)\
  if file then\
    entryFile:close()\
  end\
  os.exit()\
end\
local entryData = entryFile:read('*all')\
entryFile:close()\
local preloadEntry = {\
  path = program.params.entry,\
  name = program.params.entry:gsub('%.lua', ''):gsub('^[^%w-_]*', ''),\
}\
table.insert(preloadList, preloadEntry)\
preloadList[preloadEntry.name] = preloadEntry\
\
while #preloadList > 0 do\
  local preloadObj = preloadList[1]\
  table.remove(preloadList, 1)\
  local entryFile, err = io.open(preloadObj.path, 'r')\
  if not err then\
    console.log('build file: ' .. preloadObj.path)\
    local codeSource, is_bin = readluafile(preloadObj.path)\
    local requireSource = ''\
    if preloadObj.path:match('^%./') or preloadObj.path:match('^%.%./') or preloadObj.path:match('^/') then\
      requireSource = '\\npackage.sourceCode = package.sourceCode or {}\\npackage.sourceCode[' .. json.encode(preloadObj.name) .. '] = { path = ' .. json.encode(preloadObj.path) .. ', name = ' .. json.encode(preloadObj.name) .. ', source = ' .. qformat(codeSource) .. ' }' .. '\\n'\
    else\
      requireSource = '\\npackage.preload[\"' .. preloadObj.name .. '\"] = assert(load(' .. qformat(codeSource) .. ', \"@\" ..' .. json.encode(preloadObj.path) .. '))' .. '\\n'\
    end\
    preloadObj.sourceCode = requireSource\
    table.insert(loadedList, preloadObj.sourceCode)\
\
    local dirName = path.dirname(preloadObj.path)\
    if not is_bin then\
      -- 寻找文件require的内容\
      for value in codeSource:gmatch('require%s*%(?[\"\\']([%w-_%./\\\\]+)[\"\\']%)?') do\
        local subRequirePath = value\
        if not value:match('%.lua$') then\
          subRequirePath = value .. '.lua'\
        end\
        if subRequirePath:match('^%./') or subRequirePath:match('^%.%./') or subRequirePath:match('^/') then\
          local subRequireAbsolutePath = path.resolve(dirName, subRequirePath)\
          local obj = {\
            path = subRequireAbsolutePath,\
            name = subRequireAbsolutePath,\
          }\
          if not preloadList[obj.name] then\
            table.insert(preloadList, obj)\
            preloadList[obj.name] = obj\
          end\
        else\
          local obj = {\
            path = subRequirePath,\
            name = subRequirePath:gsub('%.lua', ''),\
          }\
          if not preloadList[obj.name] then\
            table.insert(preloadList, obj)\
            preloadList[obj.name] = obj\
          end\
        end\
      end\
    end\
  else\
    console.log(err)\
  end\
  if entryFile then\
    entryFile:close()\
  end\
end\
\
local outputFile, err = io.open(program.params.output, 'w')\
if err then\
  console.log(err)\
  if outputFile then\
    outputFile:close()\
  end\
  os.exit()\
end\
\
for k = #loadedList, 1, -1 do\
  local v = loadedList[k]\
  outputFile:write(v)\
  outputFile:write('\\n')\
end\
outputFile:write('\\nrequire(\"' .. preloadEntry.name .. '\")\\n')\
outputFile:close()\
", "@" .."index.lua"))


require("index")
