#! /usr/bin/env lua

local major, minor = assert(_VERSION:match "^Lua (%d+)%.(%d+)$")
local version = major * 10 + minor
assert(version >= 54)

local function parse(token_type, token_value, line, position)
end

-- 効率や速度は考えない
-- 改行コードはLF限定（行番号を数える際）
local function lexer(source)
  local line = 1
  local position = 1
  local _1
  local _2
  local _3
  local _4

  local function match(pattern)
    local i, j, a, b, c, d = source:find("^"..pattern, position)
    if i then
      assert(position == i)
      line = line + select(2, source:sub(position, j):gsub("\n", {}))
      position = j + 1
      _1 = a
      _2 = b
      _3 = c
      _4 = d
      return true
    else
      return false
    end
  end

  while position <= #source do
    -- 空白文字を無視する
    if match "[\f\n\r\t\v ]+" then
      -- noop

    elseif match "%-%-[^\n\r]*" then
      -- noop

    elseif match "function" then
      print(line, position, "function")

    elseif match "end" then
      print(line, position, "end")

    elseif match "%(" then
      print(line, position, "(")

    elseif match "%)" then
      print(line, position, ")")

    elseif match "([A-Za-z_][0-9A-Za-z_]*)" then
      print(line, position, "identifier", _1)

    else
      error("lexer error at line "..line)

    end

  end
end

-- Output
local source = io.read "*a"
lexer(source)
-- io.write(source)
