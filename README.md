# lua-pack

lua-pack is a module bundler for lua 5.2.

run
```
lua index.lua -e index.lua -o build.lua
```
to pack this project source code to a file

and then copy 'build.lua' to other project to pack.


Options

*  -e, --entry — Entry file name, Default is 'main.lua'
*  -o, --output — Output file name, Default is 'main-min.lua'
*  -sm, --source-code-mode — For rewrite 'require' method users. Default is false


This tool use package.preload and load() methd to pack all lua file in one.
So you can get line number when code throw error.


Packed file like this:
```
package.preload["my-modal"] = load("print(\"hellow world\")", "@/home/user/code/my-modal.lua", "bt", _ENV)
package.preload["index"] = load("require \"my-modal\"", "@/home/user/code/index.lua", "bt", _ENV)

require("index")
```
If you have anther 'require' method different to lua origin require method, you can use --sm

Packed file like this:
```
package.sourceCode = {}
package.sourceCode["my-modal"] = { path = "my-modal.lua", source = "print(\"hellow world\")" }
package.sourceCode["my-require"] = { path = "my-require.lua", source = "\"some method\"" }
package.sourceCode["index"] = { path = "index.lua", source = "require \"my-require\"\nrequire \"my-modal\" }

require("index")
```

