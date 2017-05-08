local _LICENSE = -- zlib / libpng
[[
Copyright (c) 2017 Bart van Strien

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
  claim that you wrote the original software. If you use this software
  in a product, an acknowledgment in the product documentation would be
  appreciated but is not required.

  2. Altered source versions must be plainly marked as such, and must not be
  misrepresented as being the original software.

  3. This notice may not be removed or altered from any source
  distribution.
]]

local genny =
{
	_VERSION = "1.0",
	_DESCRIPTION = "Genny enhances lua iterators",
	_URL = "https://github.com/bartbes/genny",
	_LICENSE = _LICENSE,
}

-- A generator is a lua iterator that takes no arguments

---- Generator ----
-- Turns a lua iterator into a generator
function genny.generator(it, state, init)
	return function()
		-- NOTE: If the iterator has more than 26(!) return values, they will be discarded
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = it(state, init)
		init = a
		return a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
	end
end

---- Standard generators ----
function genny.ipairs(t)
	return genny.generator(ipairs(t))
end

function genny.ripairs(t)
	local i = #t+1
	return function()
		i = i - 1
		if i == 0 then return nil end
		local v = t[i]
		return i,v
	end
end

function genny.pairs(t)
	return genny.generator(pairs(t))
end

-- All numbers from from up to and including to, with an optional step
function genny.range(from, to, step)
	step = step or 1
	if not to then
		from, to = 1, from
	end
	local it = from-step
	return function()
		if it == to then
			return nil
		end
		it = it+step
		return it
	end
end

function genny.gmatch(string, pattern)
	return genny.generator(string:gmatch(pattern))
end

-- String split
function genny.split(string, split, plain, empty)
	if empty == nil then
		empty = true
	end
	local from = 1
	local len = #string
	return function()
		if from > len then return nil end
		local to, next = string:find(split, from, plain)
		if not to then to, next = len+1, len end
		while from == to and not empty do
			from = next+1
			if from > len then return nil end
			to, next = string:find(split, from, plain)
			if not to then to, next = len+1, len end
		end
		local sub = string:sub(from, to-1)
		from = next+1
		return sub
	end
end

-- Return the given value exactly once
function genny.once(value)
	return function()
		local v = value
		value = nil
		return v
	end
end

---- Combinators ----
-- First return all values from first, then from second, etc
function genny.join(first, ...)
	local gens = {first, ...}
	local cur = 1
	return function()
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gens[cur]()
		while not a do
			cur = cur + 1
			if cur > #gens then return nil end
			a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gens[cur]()
		end
		return a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
	end
end

-- Round-robin iterations from the first, second, etc generators
function genny.roundrobin(first, ...)
	local gens = {first, ...}
	local cur = 0
	local num = #gens
	return function()
		cur = (cur % num) + 1
		return gens[cur]()
	end
end

---- Operators ----
-- Add a counter to each key, so ['a', 'b', 'c'] becomes [(1, 'a'), (2, 'b'), (3, 'c')]
function genny.enumerate(gen)
	local counter = 0
	return function()
		counter = counter + 1
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
		if a then
			return counter, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
		end
	end
end

-- Applies f to every value
function genny.map(gen, func)
	return function()
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
		if a then
			return func(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
		end
	end
end

-- Skips value if f applied to it returns false/nil
function genny.filter(gen, func)
	return function()
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
		if not a then return nil end
		while not func(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) do
			a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
			if not a then return nil end
		end
		return a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
	end
end

-- Discard the first elements keys returned (useful for ipairs)
function genny.discard(g, elements)
	elements = elements or 1
	return function()
		return select(elements+1, g())
	end
end

-- Collect all return values into a table
function genny.tablify(g)
	return function()
		local ret = {g()}
		if not ret[1] then return nil end
		return ret
	end
end

-- Take at most n elements
function genny.take(gen, max)
	local count = 0
	return function()
		count = count + 1
		if count <= max then
			return gen()
		end
	end
end

-- Take elements until 'func' returns false
function genny.when(gen, func)
	return function()
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
		if not a or not func(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z) then
			return nil
		end
		return a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z
	end
end

---- Collectors ----
-- Collect into a sequence [a, b, c] -> {a, b, c}
function genny.sequence(g)
	local out = {}
	for elem in g do
		out[#out+1] = elem
	end
	return out
end

-- Collect into a dictionary [(ka, va), (kb, vb)] -> {[ka] = va, [kb] = vb}
function genny.dictionary(g)
	local out = {}
	for k, v in g do
		out[k] = v
	end
	return out
end

-- f(state, ...) -> state
function genny.fold(gen, init, func)
	local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
	local state = init
	while a do
		state = func(state, a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
		a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z = gen()
	end
	return state
end

---- Utilities ----
local chain_mt = {
	__call = function(self)
		return self.gen()
	end,

	next = function(self, func, ...)
		self.gen = func(self.gen, ...)
		return self
	end,
}
chain_mt.__index = chain_mt

function genny.chain(g)
	return setmetatable({gen = g}, chain_mt)
end

return genny
