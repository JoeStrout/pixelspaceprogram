// This module returns the Rect class, which represents a 2D axis-aligned rectangle.
// A Rect is defined by left, bottom, width, and height.
// But functions are provided to get and set its center, top, and right sides too.

Rect = {}
Rect.left = 0
Rect.bottom = 0
Rect.width = 100
Rect.height = 100

Rect.right = function; return self.left + self.width; end function
Rect.top = function; return self.bottom + self.height; end function
Rect.centerX = function; return self.left + self.width/2; end function
Rect.centerY = function; return self.bottom + self.height/2; end function
Rect.center = function; return [self.centerX, self.centerY]; end function
Rect.area = function; return self.width * self.height; end function
Rect.isEmpty = function; return self.width == 0 or self.height == 0; end function

Rect.translate = function(dx, dy)
	self.left += dx
	self.bottom += dy
end function

Rect.setXY = function(x, y)
	self.left = x
	self.bottom = y
end function

Rect.setCenter = function(cx, cy)
	self.left = cx - self.width/2
	self.bottom = cy - self.height/2
end function

Rect.setRight = function(right)
	self.left = right - self.width
end function

Rect.setTop = function(top)
	self.bottom = top - self.height
end function

Rect.setRT = function(right, top)
	self.left = right - self.width
	self.bottom = top - self.height
end function

Rect.setLBWH = function(left, bottom, width, height)
	self.left = left
	self.bottom = bottom
	self.width = width
	self.height = height
end function

Rect.setLBRT = function(left, bottom, right, top)
	self.left = left
	self.bottom = bottom
	self.width = right - left
	self.height = top - bottom
end function

Rect.MakeLBWH = function(left, bottom, width, height)
	r = new Rect
	r.left = left
	r.bottom = bottom
	r.width = width
	r.height = height
	return r
end function

Rect.MakeLBRT = function(left, bottom, right, top)
	r = new Rect
	r.left = left
	r.bottom = bottom
	r.width = right - left
	r.height = top - bottom
	return r
end function

Rect.fixInversion = function
	if self.width < 0 then
		self.left += self.width
		self.width = -self.width
	end if
	if self.height < 0 then
		self.bottom += self.height
		self.height = -self.height
	end if
end function

Rect.inset = function(dist)
	self.left += dist
	self.bottom += dist
	self.width -= dist*2
	self.height -= dist*2
end function

Rect.outset = function(dist)
	self.inset -dist
end function

Rect.overlaps = function(other)
	return self.right > other.left and self.left < other.right and
	  self.top > other.bottom and self.bottom < other.top
end function

Rect.contains = function(x, y)
	if y == null and x isa list then
		y = x[1]
		x = x[0]
	else if y == null and x isa map then
		y = x.y
		x = x.x
	end if
	return self.left <= x < self.left + self.width and
	       self.bottom <= y < self.bottom + self.height
end function

Rect.intersection = function(other)
	return Rect.MakeLBRT(min(self.right, other.left), min(self.top, other.bottom),
	  max(self.right, other.left), max(self.top, other.bottom))
end function

Rect.union = function(other)
	return Rect.MakeLBRT(min(self.left, other.left), min(self.bottom, other.bottom),
	  max(self.right, other.right), max(self.top, other.top))
end function
	
Rect.draw = function(color = "#FFFFFF")
	gfx.fillRect self.left, self.bottom, self.width, self.height, color
end function

Rect.drawLines = function(color = "#FFFFFF", lineThickness=1)
	gfx.drawRect self.left, self.bottom, self.width, self.height, color, lineThickness
end function

runUnitTests = function
	import "qa"

	// Test MakeLBWH factory method
	r1 = Rect.MakeLBWH(10, 20, 50, 60)
	qa.assert r1.left == 10 and r1.bottom == 20
	qa.assert r1.width == 50 and r1.height == 60

	// Test getter methods: right, top, centerX, centerY, center, area
	qa.assert r1.right == 60 and r1.top == 80
	qa.assert r1.centerX == 35 and r1.centerY == 50
	qa.assert r1.center == [35, 50]
	qa.assert r1.area == 3000

	// Test MakeLBRT factory method
	r2 = Rect.MakeLBRT(10, 20, 60, 80)
	qa.assert r2.left == 10 and r2.bottom == 20
	qa.assert r2.width == 50 and r2.height == 60
	qa.assert r2.right == 60 and r2.top == 80

	// Test isEmpty
	r3 = Rect.MakeLBWH(0, 0, 0, 0)
	qa.assert r3.isEmpty
	r4 = Rect.MakeLBWH(0, 0, 10, 0)
	qa.assert r4.isEmpty
	r5 = Rect.MakeLBWH(0, 0, 0, 10)
	qa.assert r5.isEmpty
	r6 = Rect.MakeLBWH(0, 0, 10, 10)
	qa.assert not r6.isEmpty

	// Test translate
	r7 = Rect.MakeLBWH(10, 20, 50, 60)
	r7.translate 5, 10
	qa.assert r7.left == 15 and r7.bottom == 30
	qa.assert r7.width == 50 and r7.height == 60

	// Test setXY
	r8 = Rect.MakeLBWH(10, 20, 50, 60)
	r8.setXY 100, 200
	qa.assert r8.left == 100 and r8.bottom == 200
	qa.assert r8.width == 50 and r8.height == 60

	// Test setCenter
	r9 = Rect.MakeLBWH(10, 20, 50, 60)
	r9.setCenter 100, 200
	qa.assert r9.centerX == 100 and r9.centerY == 200
	qa.assert r9.left == 75 and r9.bottom == 170

	// Test setRight
	r10 = Rect.MakeLBWH(10, 20, 50, 60)
	r10.setRight 100
	qa.assert r10.right == 100
	qa.assert r10.left == 50 and r10.width == 50

	// Test setTop
	r11 = Rect.MakeLBWH(10, 20, 50, 60)
	r11.setTop 100
	qa.assert r11.top == 100
	qa.assert r11.bottom == 40 and r11.height == 60

	// Test setRT
	r12 = Rect.MakeLBWH(10, 20, 50, 60)
	r12.setRT 100, 200
	qa.assert r12.right == 100 and r12.top == 200
	qa.assert r12.left == 50 and r12.bottom == 140

	// Test setLBWH
	r13 = Rect.MakeLBWH(10, 20, 50, 60)
	r13.setLBWH 5, 15, 100, 200
	qa.assert r13.left == 5 and r13.bottom == 15
	qa.assert r13.width == 100 and r13.height == 200

	// Test setLBRT
	r14 = Rect.MakeLBWH(10, 20, 50, 60)
	r14.setLBRT 5, 10, 105, 210
	qa.assert r14.left == 5 and r14.bottom == 10
	qa.assert r14.right == 105 and r14.top == 210
	qa.assert r14.width == 100 and r14.height == 200

	// Test fixInversion with negative width
	r15 = Rect.MakeLBWH(50, 50, -20, 30)
	r15.fixInversion
	qa.assert r15.left == 30 and r15.bottom == 50
	qa.assert r15.width == 20 and r15.height == 30

	// Test fixInversion with negative height
	r16 = Rect.MakeLBWH(50, 50, 20, -30)
	r16.fixInversion
	qa.assert r16.left == 50 and r16.bottom == 20
	qa.assert r16.width == 20 and r16.height == 30

	// Test fixInversion with both negative
	r17 = Rect.MakeLBWH(50, 50, -20, -30)
	r17.fixInversion
	qa.assert r17.left == 30 and r17.bottom == 20
	qa.assert r17.width == 20 and r17.height == 30

	// Test inset
	r18 = Rect.MakeLBWH(10, 20, 100, 80)
	r18.inset 10
	qa.assert r18.left == 20 and r18.bottom == 30
	qa.assert r18.width == 80 and r18.height == 60

	// Test outset
	r19 = Rect.MakeLBWH(20, 30, 80, 60)
	r19.outset 10
	qa.assert r19.left == 10 and r19.bottom == 20
	qa.assert r19.width == 100 and r19.height == 80

	// Test contains with separate x, y
	r20 = Rect.MakeLBWH(10, 20, 50, 60)
	qa.assert r20.contains(35, 50)
	qa.assert r20.contains(10, 20)
	qa.assert not r20.contains(5, 50)
	qa.assert not r20.contains(35, 15)
	qa.assert not r20.contains(60, 50)  // right edge (exclusive)
	qa.assert not r20.contains(35, 80)  // top edge (exclusive)

	// Test contains with list
	r21 = Rect.MakeLBWH(10, 20, 50, 60)
	qa.assert r21.contains([35, 50])
	qa.assert not r21.contains([5, 50])

	// Test contains with map
	r22 = Rect.MakeLBWH(10, 20, 50, 60)
	qa.assert r22.contains({"x": 35, "y": 50})
	qa.assert not r22.contains({"x": 5, "y": 50})

	// Test overlaps - non-overlapping rects
	r23 = Rect.MakeLBWH(10, 10, 20, 20)
	r24 = Rect.MakeLBWH(50, 50, 20, 20)
	qa.assert not r23.overlaps(r24)
	qa.assert not r24.overlaps(r23)

	// Test overlaps - overlapping rects
	r25 = Rect.MakeLBWH(10, 10, 30, 30)
	r26 = Rect.MakeLBWH(20, 20, 30, 30)
	qa.assert r25.overlaps(r26)
	qa.assert r26.overlaps(r25)

	// Test overlaps - touching edges (should not overlap)
	r27 = Rect.MakeLBWH(10, 10, 20, 20)
	r28 = Rect.MakeLBWH(30, 10, 20, 20)
	qa.assert not r27.overlaps(r28)

	// Test intersection
	r29 = Rect.MakeLBWH(10, 10, 30, 30)
	r30 = Rect.MakeLBWH(20, 20, 30, 30)
	r31 = r29.intersection(r30)
	qa.assert r31.left == 20 and r31.bottom == 20
	qa.assert r31.right == 40 and r31.top == 40

	// Test union
	r32 = Rect.MakeLBWH(10, 10, 20, 20)
	r33 = Rect.MakeLBWH(40, 40, 20, 20)
	r34 = r32.union(r33)
	qa.assert r34.left == 10 and r34.bottom == 10
	qa.assert r34.right == 60 and r34.top == 60

	print "All unit tests passed."
end function


if locals == globals then
	runUnitTests
else
	return Rect
end if