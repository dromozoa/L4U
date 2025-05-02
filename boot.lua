#! /usr/bin/env lua

local major, minor = assert(_VERSION:match "^Lua (%d+)%.(%d+)$")
local version = major * 10 + minor
assert(version >= 54)

local class = {}
local metatable = { __index = class }
local _1
local _2
local _3
local _4

function class.new(source)
  return setmetatable({
    source = source;
    line = 1;
    position = 1;
  }, metatable)
end

function class:match(pattern)
  local i, j, a, b, c, d = self.source:find("^"..pattern, self.position)
  if i then
    assert(self.position == i)
    self.line = self.line + select(2, self.source:sub(self.position, j):gsub("\n", {}))
    self.position = j + 1
    _1 = a
    _2 = b
    _3 = c
    _4 = d
    return true
  else
    return false
  end
end

-- 効率や速度は考えない
-- 改行コードはLF限定（行番号を数える際）
function class:parse()
  while self.position <= #self.source do
    -- 空白文字を無視する
    if self:match "[\f\n\r\t\v ]+" then

    -- コメントを無視する
    elseif self:match "%-%-[^\n\r]*" then

    elseif self:match "function" then
      print(self.line, self.position, "function")

    elseif self:match "end" then
      print(self.line, self.position, "end")

    elseif self:match "%(" then
      print(self.line, self.position, "(")

    elseif self:match "%)" then
      print(self.line, self.position, ")")

    elseif self:match "([A-Za-z_][0-9A-Za-z_]*)" then
      print(self.line, self.position, "identifier", _1)

    else
      error("lexer error at line "..line)
    end
  end
end

local source = io.read "*a"
class.new(source):parse()
-- io.write(source)
