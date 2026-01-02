// Miscellaneous small functions, additional list/string/math utils, etc.

import "importUtil"
ensureImport "mathUtil"

// Global shortcuts for very commonly needed utility functions:
globals.min = @mathUtil.min
globals.max = @mathUtil.max

// Some list extension methods specifically for [x,y] lists:

// Return this vector minus another.
list.minus = function(other)
	return [self[0] - other[0], self[1] - other[1]]
end function

// Return the magnitude (length) of this vector.
list.magnitude = function
	return sqrt(self[0]^2 + self[1]^2)
end function

// Return the squared magnitude (length) of this vector.
// (More efficient than list.magnitude.)
list.sqrMagnitude = function
	return self[0]^2 + self[1]^2
end function

// Scale this vector in place so that its length is 1 (if possible).
list.normalize = function
	m = sqrt(self[0]^2 + self[1]^2)
	if m != 0 then
		self[0] /= m
		self[1] /= m
	end if
end function

// Function to make an [x,y] list out of a map (or another such list).
// Example usage: xyList(mouse)  -->   [103, 514]
globals.xyList = function(listOrMap)
	if listOrMap isa list then return listOrMap[0:2]
	return [listOrMap.x, listOrMap.y]
end function
