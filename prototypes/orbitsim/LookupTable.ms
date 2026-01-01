// LookupTable: wraps a list of numbers with floating-point index lookup.
// Interpolates between adjacent values and wraps around for out-of-range indices.

LookupTable = {}
LookupTable.data = null

// make: create a new LookupTable wrapping the given list of numbers
LookupTable.Make = function(list)
	result = new LookupTable
	result.data = list[:]  // shallow copy
	return result
end function

// lookup: get a value at a floating-point index.
// Interpolates linearly between adjacent values.
// Wraps around for indices outside [0, len).
LookupTable.lookup = function(idx)
	n = self.data.len
	if n == 0 then return null
	if n == 1 then return self.data[0]

	// Wrap idx to valid range [0, n)
	idx = idx % n
	if idx < 0 then idx = idx + n

	// Get integer and fractional parts
	i0 = floor(idx)
	frac = idx - i0

	// Handle the case where i0 is exactly n-1 after flooring
	if i0 >= n then i0 = 0

	// Next index, with wraparound
	i1 = (i0 + 1) % n

	// Linear interpolation
	v0 = self.data[i0]
	v1 = self.data[i1]
	return v0 + (v1 - v0) * frac
end function

runUnitTests = function
	import "qa"

	// Basic integer index lookups
	globals.t = LookupTable.Make([10, 20, 30, 40])
	qa.assertEqual t.lookup(0), 10
	qa.assertEqual t.lookup(1), 20
	qa.assertEqual t.lookup(2), 30
	qa.assertEqual t.lookup(3), 40

	// Fractional index lookups (interpolation)
	qa.assertEqual t.lookup(0.5), 15   // halfway between 10 and 20
	qa.assertEqual t.lookup(1.5), 25   // halfway between 20 and 30
	qa.assertEqual t.lookup(2.5), 35   // halfway between 30 and 40
	qa.assertEqual t.lookup(0.25), 12.5
	qa.assertEqual t.lookup(0.75), 17.5

	// Wraparound at the end (index 3.5 is halfway between 40 and 10)
	qa.assertEqual t.lookup(3.5), 25   // halfway between 40 and 10
	qa.assertEqual t.lookup(3.75), 17.5

	// Wraparound with indices >= len
	qa.assertEqual t.lookup(4), 10     // same as index 0
	qa.assertEqual t.lookup(5), 20     // same as index 1
	qa.assertEqual t.lookup(4.5), 15   // same as index 0.5
	qa.assertEqual t.lookup(8.25), 12.5  // same as index 0.25

	// Negative index wraparound
	qa.assertEqual t.lookup(-1), 40    // wraps to index 3
	qa.assertEqual t.lookup(-0.5), 25  // halfway between 10 and 40
	qa.assertEqual t.lookup(-2), 30    // wraps to index 2
	qa.assertEqual t.lookup(-4), 10    // wraps to index 0
	qa.assertEqual t.lookup(-4.5), 25  // wraps to index 3.5

	// Edge case: single element list
	t1 = LookupTable.Make([42])
	qa.assertEqual t1.lookup(0), 42
	qa.assertEqual t1.lookup(0.5), 42
	qa.assertEqual t1.lookup(5), 42
	qa.assertEqual t1.lookup(-3), 42

	// Edge case: two element list
	t2 = LookupTable.Make([0, 100])
	qa.assertEqual t2.lookup(0), 0
	qa.assertEqual t2.lookup(1), 100
	qa.assertEqual t2.lookup(0.5), 50
	qa.assertEqual t2.lookup(1.5), 50   // halfway between 100 and 0
	qa.assertEqual t2.lookup(-0.5), 50  // wraps to 1.5

	// Edge case: empty list
	t0 = LookupTable.Make([])
	qa.assertEqual t0.lookup(0), null
	qa.assertEqual t0.lookup(5), null

	print "All LookupTable tests passed!"
end function

if locals == globals then runUnitTests else return LookupTable
