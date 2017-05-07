Genny is a lua libraries for working with generators.

Lua defines iterators that can be used with for loops.
Unfortunately, since they are defined as 3 separate values, it is very hard to manipulate these iterators.
Genny defines so-called "generators", which nothing but lua iterators that don't take any arguments.
Since this means a generator is a single (callable) value, it's much easier to pass them around, manipulate them, store them, etc.

For documentation see [here][docs].
The tests (in `genny_spec.lua`) can be run using [busted][].

[docs]: https://docs.bartbes.com/genny
[busted]: https://olivinelabs.com/busted/
