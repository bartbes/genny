package = "genny"
version = "scm-1"

source = {
	url = "git://github.com/bartbes/genny",
	dir = "genny",
}

description = {
	summary = "Genny is a lua libraries for working with generators.",
	detailed = [[
		Lua defines iterators that can be used with for loops. Unfortunately,
		since they are defined as 3 separate values, it is very hard to
		manipulate these iterators. Genny defines so-called "generators", which
		nothing but lua iterators that don't take any arguments. Since this
		means a generator is a single (callable) value, it's much easier to
		pass them around, manipulate them, store them, etc.
	]],
	homepage = "http://docs.bartbes.com/genny",
	license = "zlib"
}

dependencies = {
	"lua >= 5.1",
}

build = {
	type = "builtin",
	modules = {
		genny = "genny.lua"
	}
}
