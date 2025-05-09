#! /usr/bin/env lua

local command, filename = ...

local function pattern(pattern)
  return function (source, position)
    return string.find(source, "^"..pattern, position)
  end
end

local rules = {
  { pattern "%s+", false };
  { pattern "%-%-[^\n\r]*", false };
  { pattern "0[xX]%x+", "INTEGER" };
  { pattern "%d+", "INTEGER" };
  { "=", "EQ" };
  { "local" };
  { pattern "[%a_][%w_]*", "NAME" };
}

local token_eof = 1000
local tokens = {
  map = {};
  {
    id = token_eof;
    name = "EOF";
  };
}

for _, rule in ipairs(rules) do
  local def, name = rule[1], rule[2]
  local def_is_string = type(def) == "string"

  if def_is_string then
    rule[1] = function (source, position)
      local i = position
      local j = i + #def - 1
      if source:sub(i, j) == def then
        return i, j
      end
    end
    if name == nil then
      name = def:upper()
      rule[2] = name
    end
  end
  if name then
    assert(name:match "^[%u_]+$")

    local token = tokens.map[name]
    if not token then
      local n = #tokens
      token = {
        id = n + token_eof;
        name = name;
        capture = not def_is_string;
      }
      tokens.map[name] = token
      tokens[n + 1] = token
    end
    rule[3] = token
  end
end

if command == "update" then
  local ih = assert(io.open(filename))
  local oh = assert(io.open(filename..".new", "w"))

  local state = 1
  for line in ih:lines() do
    if state == 1 then
      oh:write(line, "\n")
      if line == "// BEGIN TOKENS" then
        state = 2
        for _, token in ipairs(tokens) do
          oh:write "%token "
          if token.capture then
            oh:write "<std::string> "
          end
          oh:write(token.name, " ", token.id, "\n")
        end
      end
    elseif state == 2 then
      if line == "// END TOKENS" then
        oh:write(line, "\n")
        state = 3
      end
    else
      oh:write(line, "\n")
    end
  end

  assert(os.rename(filename..".new", filename))
  return
end

local source = io.read "*a"

local position = 1
local line = 1
local column = 1

while position <= #source do
  local i, j, token
  for _, rule in ipairs(rules) do
    i, j = rule[1](source, position)
    if i then
      token = rule[3]
      break
    end
  end
  if not i then
    error("lexer error at position "..position)
  end

  position = j + 1
  if token then
    print(i, j, token.name)
  end
end
