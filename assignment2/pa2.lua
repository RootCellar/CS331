#!/usr/bin/env lua
--
--
--

local pa2 = {}

function pa2.mapTable(f, t)

  toRet = {}

  for k, v in pairs(t) do
    toRet[k] = f(v)
  end

  return toRet

end

function pa2.concatMax(s, l)

  toRet = ""

  while string.len(toRet) + string.len(s) <= l do
    toRet = toRet..s
  end

  return toRet
end

function pa2.collatz()

end

function pa2.backSubs()
end

return pa2
