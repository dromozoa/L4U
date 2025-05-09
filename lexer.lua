#! /usr/bin/env lua

local command = ...

local function pattern(pattern)
  return function (source, position)
    return string.find(source, "^"..pattern, position)
  end
end

local rules = {
  { pattern "%s+", false };
  { pattern "0[xX]%x+", "INTEGER" };
  { pattern "%d+", "INTEGER" };
  { "=", "EQ" };
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
    rules[2] = token
  end
end

if command == "update" then
  local ih = assert(io.open("parser.yy"))
  local oh = assert(io.open("parser.yy.new", "w"))

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

  assert(os.rename("parser.yy.new", "parser.yy"))
end
