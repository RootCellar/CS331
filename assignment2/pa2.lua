#!/usr/bin/env lua
-- Darian Marvel
-- 2/8/2022
-- Completing Assignment 2 Exercise 2

local pa2 = {}

function pa2.mapTable(f, t)

  local toRet = {}

  for k, v in pairs(t) do
    toRet[k] = f(v)
  end

  return toRet

end

function pa2.concatMax(s, l)

  local toRet = ""

  while string.len(toRet) + string.len(s) <= l do
    toRet = toRet..s
  end

  return toRet
end

function pa2.collatz(k)
  local oldk = k
  return function()
    oldk = k
    if k == 0 then
      return
    end

    if k == 1 then
      k = 0
      return 1
    end

    if k%2 == 0 then
      k = k / 2
    else
      k = 3 * k + 1
    end

    return oldk

  end
end

function pa2.backSubs(s)

  local s = string.reverse(s)
  local length = string.len(s)
  local sublen = 1
  local toRet = {}

  coroutine.yield("")

  for i=0,length,1 do
    local k = 1
    while k + i <= length do
      coroutine.yield(string.sub(s, k, k+i))
      k = k + 1
    end
  end


end

return pa2
