// Miscellaneous small functions, additional list/string/math utils, etc.

import "importUtil"
ensureImport "mathUtil"

// Global shortcuts for very commonly needed utility functions:
globals.min = @mathUtil.min
globals.max = @mathUtil.max

// Helpers to conver radias to degrees and viceversa
// just multiply your angle with one of these to convert
globals.deg2rad = pi / 180
globals.rad2deg = 180 / pi

// Some list extension methods specifically for [x,y] lists:

// Accessors so you can use pos.x as a synonym for pos[0], etc.
// Note that you can only use these to READ the values; do NOT
// use them to assign new values!  You must assign to v[0], v[1], etc.
// (Technically `v.anything = whatever` will always update v[0],
// because MiniScript takes the `val` of whatever's to the right of
// the dot to find the numeric index, and that will always be 0.)
list.x = function; return self[0]; end function
list.y = function; return self[1]; end function

// Return this vector minus another.
list.minus = function(other)
	return [self[0] - other[0], self[1] - other[1]]
end function

// Return this vector plus another.
list.plus = function(other)
	return [self[0] + other[0], self[1] + other[1]]
end function

// Return this vector times another.
list.times = function(other)
	return [self[0] * other[0], self[1] * other[1]]
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

list.distanceTo = function(other)
	dx = other[0] - self[0]
	dy = other[1] - self[1]
	return sqrt(dx * dx + dy * dy)
end function

// Dot product
list.dot = function(other)
	return self[0] * other[0] + self[1] * other[1]
end function

list.angleTo = function(other)
	return atan((other[1] - self[1]), (other[0] - self[0])) * rad2deg 
end function

// Rotates the [x,y] a certain amount of degrees counter-clockwise
// i.e: [1, 0].rotate 90 = [0, 1]
list.rotate = function(angle)
	cosA = cos(angle * deg2rad)
	sinA = sin(angle * deg2rad)
	
	x = self[0] * cosA - self[1] * sinA
	y = self[0] * sinA + self[1] * cosA
	
	// Rounded 5 decimal values to make the result more clear
	self[0] = round(x, 5)
	self[1] = round(y, 5)
end function

// Function to make an [x,y] list out of a map (or another such list).
// Example usage: xyList(mouse)  -->   [103, 514]
globals.xyList = function(listOrMap)
	if listOrMap isa list then return listOrMap[0:2]
	return [listOrMap.x, listOrMap.y]
end function

// Get a temp PixelDisplay for compositing etc.
_tempG = null
globals.tempG = function(width=512, height=512, color="#00000000")
	if _tempG == null then outer._tempG = new PixelDisplay
	_tempG.clear color, width, height
	return _tempG
end function
