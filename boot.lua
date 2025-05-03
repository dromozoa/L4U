#! /usr/bin/env lua

local major, minor = assert(_VERSION:match "^Lua (%d+)%.(%d+)$")
local version = major * 10 + minor
assert(version >= 54)

-- 効率や速度は考えない
-- 改行コードはLF限定（行番号を数える際）
local function lexer(source)
  local position = 1
  local line = 1

  local function _(pattern, name, conv)
    local i, j, v = source:find("^"..pattern, position)
    if i then
      assert(i == position)
      local s = source:sub(i, j)
      local v = v or s

      local token = {
        i = i;
        j = j;
        line = line;
        name = name == nil and s or name;
        source = s;
        value = conv == nil and v or conv(v);
      }

      position = j + 1
      line = line + select(2, s:gsub("\n", {}))

      return token
    end
  end

  local tokens = {}
  while position <= #source do
    local token
      =  _("%s+", false)
      or _("%-%-[^\n\r]*", false)
      or _("0[xX]%x+", "integer", tonumber)
      or _("%d+", "integer", tonumber)

      or _"and"
      or _"break"
      or _"do"
      or _"else"
      or _"elseif"
      or _"end"
      or _"false"
      or _"for"
      or _"function"
      or _"goto"
      or _"if"
      or _"in"
      or _"local"
      or _"nil"
      or _"not"
      or _"or"
      or _"repeat"
      or _"return"
      or _"then"
      or _"true"
      or _"until"
      or _"while"

      or _"%+"
      or _"%-"
      or _"%*"
      or _"/"
      or _"%%"
      or _"%^"
      or _"#"
      or _"&"
      or _"~"
      or _"|"
      or _"<<"
      or _">>"
      or _"//"
      or _"=="
      or _"~="
      or _"<="
      or _">="
      or _"<"
      or _">"
      or _"="
      or _"%("
      or _"%)"
      or _"{"
      or _"}"
      or _"%["
      or _"%]"
      or _"::"
      or _";"
      or _":"
      or _","
      or _"%."
      or _"%.%."
      or _"%.%.%."

      or _("[A-Za-z][0-9A-Za-z]*", "name")

    if not token then
      print(position)
      error("lexer error at line "..line)
    end

    if token.name then
      print(token.name, token.value, token.line)
      table.insert(tokens, token)
    end

  end

  return tokens
end

local class = {}
local metatable = { __index = class }

function class.new(source)
  return setmetatable({}, metatable)
end

function class:parse()
end

local source = io.read "*a"
lexer(source)
-- io.write(source)
