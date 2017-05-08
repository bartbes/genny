local genny = require "genny"

describe("A generator", function()
	it("matches the output of its iterator", function()
		local t = {1, 2, 3, 4, 5}

		local ipairs_output = {}
		local gen_output = {}

		for i, v in ipairs(t) do
			table.insert(ipairs_output, {i, v})
		end

		for i, v in genny.generator(ipairs(t)) do
			table.insert(gen_output, {i, v})
		end

		assert.are.same(ipairs_output, gen_output)
	end)

	it("requires no arguments", function()
		local t = {1, 2}
		local out = {}
		for i, v in genny.generator(ipairs(t)), 5, 4 do
			table.insert(out, v)
		end

		assert.are.same(t, out)
	end)
end)

describe("The standard generator", function()
	describe("ipairs", function()
		it("matches generator(ipairs)", function()
			local t = {1, 2, 3, 4, 5}

			local ipairs_output = {}
			local gen_output = {}

			for i, v in genny.ipairs(t) do
				table.insert(ipairs_output, {i, v})
			end

			for i, v in genny.generator(ipairs(t)) do
				table.insert(gen_output, {i, v})
			end

			assert.are.same(ipairs_output, gen_output)
		end)
	end)

	describe("ripairs", function()
		it("is the reverse of generator(ipairs)", function()
			local t = {1, 2, 3, 4, 5}

			local ipairs_output = {}
			local gen_output = {}

			for i, v in genny.ripairs(t) do
				table.insert(ipairs_output, {i, v})
			end

			for i, v in genny.generator(ipairs(t)) do
				table.insert(gen_output, 1, {i, v})
			end

			assert.are.same(ipairs_output, gen_output)
		end)
	end)

	describe("pairs", function()
		it("matches generator(pairs)", function()
			local t = {a = 5, b = 7, cake = "a"}

			local pairs_output = {}
			local gen_output = {}

			for i, v in genny.pairs(t) do
				pairs_output[i] = v
			end

			for i, v in genny.generator(pairs(t)) do
				gen_output[i] = v
			end

			assert.are.same(pairs_output, gen_output)
		end)
	end)

	describe("range", function()
		it("returns all elements in a range", function()
			local target = {5, 6, 7, 8, 9}
			local output = {}

			for n in genny.range(5, 9) do
				table.insert(output, n)
			end

			assert.are.same(target, output)
		end)

		it("handles an empty range", function()
			local ran = 0
			for n in genny.range(6, 5) do
				ran = ran + 1
			end
			assert.is.equal(ran, 0)
		end)

		it("handled a range of length 1", function()
			local ran = 0
			for n in genny.range(6, 6) do
				ran = ran + 1
				assert.is.equal(n, 6)
			end
			assert.is.equal(ran, 1)
		end)

		it("has an optional from argument", function()
			local target = {1, 2, 3, 4, 5}
			local output = {}

			for n in genny.range(5) do
				table.insert(output, n)
			end

			assert.are.same(target, output)
		end)

		it("has an optional step argument", function()
			local target = {1, 3, 5}
			local output = {}

			for n in genny.range(1, 5, 2) do
				table.insert(output, n)
			end

			assert.are.same(target, output)

			local target = {5, 4, 3, 2, 1}
			local output = {}

			for n in genny.range(5, 1, -1) do
				table.insert(output, n)
			end

			assert.are.same(target, output)
		end)
	end)

	describe("gmatch", function()
		it("matches generator(gmatch)", function()
			local s = "1,2,,3,4"

			local gmatch_output = {}
			local gen_output = {}

			for part in genny.gmatch(s, ",") do
				table.insert(gmatch_output, part)
			end

			for part in genny.generator(s:gmatch(",")) do
				table.insert(gen_output, part)
			end

			assert.are.same(gen_output, gmatch_output)
		end)
	end)

	describe("split", function()
		it("splits properly", function()
			local s = "1,2,3,4"

			local split_output = {}

			for part in genny.split(s, ",") do
				table.insert(split_output, part)
			end

			assert.are.same({"1", "2", "3", "4"}, split_output)
		end)

		it("does pattern splits", function()
			local s = "1,2;3;4"

			local split_output = {}

			for part in genny.split(s, "[,;]") do
				table.insert(split_output, part)
			end

			assert.are.same({"1", "2", "3", "4"}, split_output)
		end)

		it("does plain splits", function()
			local s = "1.2.3.4"

			local split_output = {}

			for part in genny.split(s, ".", true) do
				table.insert(split_output, part)
			end

			assert.are.same({"1", "2", "3", "4"}, split_output)
		end)

		it("works with empty parts", function()
			local s = "1,2,,3,4"

			local split_output = {}

			for part in genny.split(s, ",", true, true) do
				table.insert(split_output, part)
			end

			assert.are.same({"1", "2", "", "3", "4"}, split_output)
		end)

		it("can skip empty parts", function()
			local s = "1,2,,3,4"

			local split_output = {}

			for part in genny.split(s, ",", true, false) do
				table.insert(split_output, part)
			end

			assert.are.same({"1", "2", "3", "4"}, split_output)
		end)
	end)

	describe("once", function()
		it("returns the exact value given", function()
			local value = {}
			local target = value
			local output = nil

			for v in genny.once(value) do
				output = v
			end

			assert.are.equal(target, output)
		end)

		it("return the value exactly once", function()
			local value = 15
			local target = {15}
			local output = {}

			for v in genny.once(value) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)
	end)
end)

describe("The combinator", function()
	describe("join", function()
		it("is the identity with one iterator", function()
			local t = {1, 2, 3}
			local target = {1, 2, 3}
			local output = {}

			for i, v in genny.join(genny.ipairs(t)) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can join two generators", function()
			local t = {1, 2, 3}
			local target = {1, 2, 3, 1, 2, 3}
			local output = {}

			for i, v in genny.join(genny.ipairs(t), genny.ipairs(t)) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can join three generators", function()
			local t = {1, 2, 3}
			local s = "aaabaa"
			local target = {1, 2, 3, "aaa", "aa", 1, 2, 3}
			local output = {}

			for i, v in genny.join(genny.ipairs(t), genny.gmatch(s, "a+"), genny.ipairs(t)) do
				-- Note: I'm using i since gmatch only returns one element
				table.insert(output, i)
			end

			assert.are.same(target, output)
		end)
	end)

	describe("roundrobin", function()
		it("is the identity with one iterator", function()
			local t = {1, 2, 3}
			local target = {1, 2, 3}
			local output = {}

			for i, v in genny.roundrobin(genny.ipairs(t)) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can roundrobin two generators", function()
			local t = {1, 2, 3}
			local target = {1, 1, 2, 2, 3, 3}
			local output = {}

			for i, v in genny.roundrobin(genny.ipairs(t), genny.ipairs(t)) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can join three generators", function()
			local t = {1, 2, 3}
			local s = "aaabaa"
			local target = {1, "aaa", 1, 2, "aa", 2, 3}
			local output = {}

			for i, v in genny.roundrobin(genny.ipairs(t), genny.gmatch(s, "a+"), genny.ipairs(t)) do
				-- Note: I'm using i since gmatch only returns one element
				table.insert(output, i)
			end

			assert.are.same(target, output)
		end)
	end)
end)

describe("The operator", function()
	describe("enumerate", function()
		it("prefixes every iteration with an iteration number", function()
			local s = "abc"
			local target = {{1, "a"}, {2, "b"}, {3, "c"}}
			local output = {}

			for i, v in genny.enumerate(genny.gmatch(s, ".")) do
				table.insert(output, {i, v})
			end

			assert.are.same(target, output)
		end)

		it("works across joins", function()
			local s = "abc"
			local target = {{1, "a"}, {2, "b"}, {3, "c"}, {4, "a"}, {5, "b"}, {6, "c"}}
			local output = {}

			for i, v in genny.enumerate(genny.join(genny.gmatch(s, "."), genny.gmatch(s, "."))) do
				table.insert(output, {i, v})
			end

			assert.are.same(target, output)
		end)

		it("works inside joins", function()
			local s = "abc"
			local target = {{1, "a"}, {2, "b"}, {3, "c"}, {1, "a"}, {2, "b"}, {3, "c"}}
			local output = {}

			for i, v in genny.join(genny.enumerate(genny.gmatch(s, ".")), genny.enumerate(genny.gmatch(s, "."))) do
				table.insert(output, {i, v})
			end

			assert.are.same(target, output)
		end)
	end)

	describe("map", function()
		it("calls the mapper exactly once for every element", function()
			local t = {1, 2, 3}
			local target = t
			local output = {}

			local function f(i, v)
				table.insert(output, v)
				return i, v
			end

			for i, v in genny.map(genny.ipairs(t), f) do
			end

			assert.are.same(target, output)
		end)

		it("uses the return values of map", function()
			local t = {1, 2, 3}
			local target = {{4, 2}, {3, 3}, {2, 4}}
			local output = {}

			local function f(i, v)
				return 5-i, v+1
			end

			for i, v in genny.map(genny.ipairs(t), f) do
				table.insert(output, {i, v})
			end

			assert.are.same(target, output)
		end)

		it("can drop return values", function()
			local t = {1, 2, 3}
			local target = {1, 2, 3}
			local output = {}

			local function f(i, v)
				return v
			end

			for v in genny.map(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can add return values", function()
			local t = {1, 2, 3}
			local target = {{1, 1, "b"}, {2, 2, "c"}, {3, 3, "d"}}
			local output = {}

			local function f(i, v)
				return i, v, string.char(string.byte("a")+v)
			end

			for i, v, c in genny.map(genny.ipairs(t), f) do
				table.insert(output, {i, v, c})
			end

			assert.are.same(target, output)
		end)

		-- blame lua semantics
		it("can stop looping early", function()
			local t = {1, 2, 3}
			local target = {1}
			local output = {}

			local function f(i, v)
				if v == 2 then return nil end
				return i, v
			end

			for i, v in genny.map(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)
	end)

	describe("filter", function()
		it("can filter out iterations in the middle", function()
			local t = {1, 2, 3}
			local target = {1, 3}
			local output = {}

			local function f(i, v)
				return v % 2 ~= 0
			end

			for i, v in genny.filter(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can filter out iterations at the start", function()
			local t = {1, 2, 3}
			local target = {2, 3}
			local output = {}

			local function f(i, v)
				return v >= 2
			end

			for i, v in genny.filter(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can filter out iterations at the end", function()
			local t = {1, 2, 3}
			local target = {1, 2}
			local output = {}

			local function f(i, v)
				return v <= 2
			end

			for i, v in genny.filter(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can filter out all iterations", function()
			local t = {1, 2, 3}
			local target = {}
			local output = {}

			local function f(i, v)
				return false
			end

			for i, v in genny.filter(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)

		it("can filter out no iterations", function()
			local t = {1, 2, 3}
			local target = t
			local output = {}

			local function f(i, v)
				return true
			end

			for i, v in genny.filter(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.are.same(target, output)
		end)
	end)

	describe("discard", function()
		it("can discard no return values", function()
			local t = {4, 5, 6}
			local target = {{1, 4}, {2, 5}, {3, 6}}
			local output = {}

			for i, v in genny.discard(genny.ipairs(t), 0) do
				table.insert(output, {i, v})
			end

			assert.is.same(target, output)
		end)

		it("can discard one return value", function()
			local t = {4, 5, 6}
			local target = {{4}, {5}, {6}}
			local output = {}

			for i, v in genny.discard(genny.ipairs(t), 1) do
				table.insert(output, {i, v})
			end

			assert.is.same(target, output)
		end)

		it("defaults to discarding one return value", function()
			local t = {4, 5, 6}
			local target = {{4}, {5}, {6}}
			local output = {}

			for i, v in genny.discard(genny.ipairs(t)) do
				table.insert(output, {i, v})
			end

			assert.is.same(target, output)
		end)

		it("can discard two return values", function()
			local t = {4, 5, 6}
			local target = {{4}, {5}, {6}}
			local output = {}

			for i, v in genny.discard(genny.enumerate(genny.ipairs(t)), 2) do
				table.insert(output, {i, v})
			end

			assert.is.same(target, output)
		end)

		it("can discard all return values, stopping iteration", function()
			local t = {4, 5, 6}
			local ran = false

			for i, v in genny.discard(genny.ipairs(t), 2) do
				ran = true
			end

			assert.is_false(ran)
		end)
	end)

	describe("tablify", function()
		it("gathers all return values into a table", function()
			local t = {4, 5, 6}
			local target = {{1, 4}, {2, 5}, {3, 6}}
			local output = {}

			for v in genny.tablify(genny.ipairs(t)) do
				table.insert(output, v)
			end

			assert.is.same(target, output)
		end)
	end)

	describe("take", function()
		it("returns at most n elements", function()
			local t = {1, 2, 3, 4, 5}
			local target = {1, 2, 3}
			local output = {}

			for i, v in genny.take(genny.ipairs(t), 3) do
				table.insert(output, v)
			end

			assert.is.same(target, output)

			local t = {1, 2, 3}
			local output = {}

			for i, v in genny.take(genny.ipairs(t), 5) do
				table.insert(output, v)
			end

			assert.is.same(target, output)
		end)
	end)

	describe("when", function()
		it("returns elements until func returns false", function()
			local t = {1, 2, 3, 4, 5}
			local target = {1, 2, 3}
			local output = {}

			local function f(i, v)
				return v ~= 4
			end

			for i, v in genny.when(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.is.same(target, output)

			local target = {1, 2, 3, 4, 5}
			local output = {}

			local function f(i, v)
				return v ~= 7
			end

			for i, v in genny.when(genny.ipairs(t), f) do
				table.insert(output, v)
			end

			assert.is.same(target, output)
		end)
	end)
end)

describe("The collector", function()
	describe("sequence", function()
		it("collects all first return values into a sequence", function()
			local t = {4, 5, 6}
			local target = {1, 2, 3}
			local output = genny.sequence(genny.ipairs(t))
			assert.is.same(target, output)

			local s = "aaabaa"
			local target = {"aaa", "aa"}
			local output = genny.sequence(genny.gmatch(s, "a+"))
			assert.is.same(target, output)
		end)

		it("combines well with tablify", function()
			local t = {4, 5, 6}
			local target = {{1, 4}, {2, 5}, {3, 6}}
			local output = genny.sequence(genny.tablify(genny.ipairs(t)))
			assert.is.same(target, output)
		end)

		it("combines well with discard", function()
			local t = {4, 5, 6}
			local target = t
			local output = genny.sequence(genny.discard(genny.ipairs(t)))
			assert.is.same(target, output)
		end)
	end)

	describe("dictionary", function()
		it("uses the first two return values to build a dictionary", function()
			local t = {4, 5, 6}
			local target = {4, 5, 6}
			local output = genny.dictionary(genny.ipairs(t))
			assert.is.same(target, output)

			local s = "a=b;c=d;"
			local target = {a = "b", c = "d"}
			local output = genny.dictionary(genny.gmatch(s, "(.-)=(.-);"))
			assert.is.same(target, output)
		end)

		it("combines well with enumerate", function()
			local s = "aaabaa"
			local target = {"aaa", "aa"}
			local output = genny.dictionary(genny.enumerate(genny.gmatch(s, "a+")))
			assert.is.same(target, output)
		end)
	end)

	describe("fold", function()
		it("is called exactly once for every iteration", function()
			local t = {1, 2, 3}
			local target = 3

			local function f(state, i, v)
				return state + 1
			end

			local output = genny.fold(genny.ipairs(t), 0, f)
			assert.is.equal(target, output)
		end)

		it("is called in iteration order", function()
			local t = {1, 2, 3}
			local target = t

			local function f(state, i, v)
				table.insert(state, v)
				return state
			end

			local output = genny.fold(genny.ipairs(t), {}, f)
			assert.is.same(target, output)
		end)

		it("receives all values", function()
			local t = {1, 2, 3}
			local target = 12

			local function f(state, i, v)
				return state + i + v
			end

			local output = genny.fold(genny.ipairs(t), 0, f)
			assert.is.equal(target, output)
		end)
	end)
end)

describe("The utility", function()
	describe("chain", function()
		it("prevents deep nesting", function()
			local s = "a=b;c=d;"
			local target = {[4] = "D"}

			local function filter(k, v)
				return k == "c"
			end

			local function mapper(k, v)
				return 4*k, v
			end

			local chain = genny.chain(genny.gmatch(s, "(.-)=(.-);")) -- (a, b), (c, d)
				:next(genny.filter, filter) -- (c, d)
				:next(genny.discard) -- d
				:next(genny.map, string.upper) -- D
				:next(genny.enumerate) -- (1, D)
				:next(genny.map, mapper) -- (4, D)

			local output = genny.dictionary(chain)
			assert.is.same(target, output)
		end)
	end)
end)
