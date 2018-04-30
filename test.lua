require 'string-split'
local json = require 'json'
local path = require 'path'
console = require 'console'

local test = "require './string-split'"
console.log(test:match('require%s*%(?["\']([%w-_./\\]+)["\']%)?'))
