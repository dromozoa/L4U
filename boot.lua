#! /usr/bin/env lua

local major, minor = assert(_VERSION:match "^Lua (%d+)%.(%d+)$")
local version = major * 10 + minor
assert(version >= 54)

-- 効率や速度はおいておく
-- 行番号を数える際の改行コードはLF限定
-- 浮動小数点数はサポートしない
local function lexer(source)
  local position = 1
  local line = 1

  local function make_token(name, i, j, v)
    local s = source:sub(i, j)

    local token = {
      i = i;
      j = j;
      line = line;
      name = name == nil and s or name;
      source = s;
      value = v or s;
    }

    position = j + 1
    line = line + select(2, s:gsub("\n", {}))

    return token
  end

  local function _(pattern, name, conv)
    local i, j, v = source:find("^"..pattern, position)
    if i then
      if conv then
        v = conv(assert(v))
      end
      return make_token(name, i, j, v)
    end
  end

  local function LongComment()
    local i, j, v = source:find("^%-%-%[(=*)%[\n?", position)
    if i then
      local k, l = source:find("%]"..v.."%]", j + 1)
      if not k then
        error("unfinished long comment at line "..line)
      end
      return make_token(false, i, l, source:sub(j + 1, k - 1))
    end
  end

  local function LongStringLiteral()
    local i, j, v = source:find("^%[(=*)%[\n?", position)
    if i then
      local k, l = source:find("%]"..v.."%]", j + 1)
      if not k then
        error("unfinished long string literal at line "..line)
      end
      return make_token("StringLiteral", i, l, source:sub(j + 1, k - 1))
    end
  end

  local function ShortStringLiteral()
    local i, j, v = source:find("^([\"'])", position)
    if i then
      local k, l = source:find("[^\\]"..v, position)
      if not k then
        error("unfinished short string literal at line "..line)
      end
      local v = source:sub(i + 1, k)
        :gsub("\\([abfnrtv\\\"'])", {
          a = "\a", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t", v = "\v";
          ["\\"] = "\\";
          ["\""] = "\"";
          ["'"] = "'";
        })
        :gsub("\\z%s+", "")
        :gsub("\\x(%x%x)", function (v)
          return string.char(tonumber(v, 16))
        end)
        :gsub("\\(%d%d?%d?)", function (v)
          return string.char(tonumber(v, 10))
        end)
        :gsub("\\u{(%x+)}", function (v)
          return utf8.char(tonumber(v, 16))
        end)
      return make_token("StringLiteral", i, l, v)
    end
  end

  local tokens = {}
  while position <= #source do
    local token
      =  _("%s+", false)

      -- comment
      or LongComment()
      or _("%-%-([^\n\r]*)", false)

      -- string
      or LongStringLiteral()
      or ShortStringLiteral()

      -- Numeral
      or _("(0[xX]%x+)", "IntegerNumeral", tonumber)
      or _("(%d+)", "IntegerNumeral", tonumber)

      -- https://www.lua.org/manual/5.4/manual.html#3.1
      or _"and"   or _"break" or _"do"       or _"else" or _"elseif" or _"end"
      or _"false" or _"for"   or _"function" or _"goto" or _"if"     or _"in"
      or _"local" or _"nil"   or _"not"      or _"or"   or _"repeat" or _"return"
      or _"then"  or _"true"  or _"until"    or _"while"

      or _"%+" or _"%-" or _"%*" or _"/"  or _"%%"   or _"%^" or _"#"
      or _"&"  or _"~"  or _"|"  or _"<<" or _">>"   or _"//"
      or _"==" or _"~=" or _"<=" or _">=" or _"<"    or _">"  or _"="
      or _"%(" or _"%)" or _"{"  or _"}"  or _"%["   or _"%]" or _"::"
      or _";"  or _":"  or _","  or _"%." or _"%.%." or _"%.%.%."

      or _("[%a_][%w_]*", "Name")

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
