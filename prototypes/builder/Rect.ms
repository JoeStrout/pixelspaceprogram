// max: returns the greater of two values.
max = function(a, b)
	if b > a then return b else return a
end function

// min: returns the lesser of two values.
min = function(a, b)
	if b < a then return b else return a
end function

Rect = {}
Rect.x = 0  // left
Rect.y = 0  // top
Rect.width = 100
Rect.height = 100

Rect.right = function; return self.x + self.width; end function
Rect.bottom = function; return self.y + self.height; end function
Rect.centerX = function; return self.x + self.width/2; end function
Rect.centerY = function; return self.y + self.height/2; end function
Rect.center = function; return [self.centerX, self.centerY]; end function
Rect.area = function; return self.width * self.height; end function
Rect.isEmpty = function; return self.width == 0 or self.height == 0; end function

Rect.translate = function(dx, dy)
	self.x += dx
	self.y += dy
end function

Rect.setXY = function(x, y)
	self.x = x
	self.y = y
end function

Rect.setCenter = function(cx, cy)
	self.x = x - self.width/2
	self.y = y - self.height/2
end function

Rect.setRight = function(right)
	self.x = right - self.width
end function

Rect.setBottom = function(bottom)
	self.y = bottom - self.height
end function

Rect.setRB = function(right, bottom)
	self.x = right - self.width
	self.y = bottom - self.height
end function

Rect.setLTWH = function(left, top, width, height)
	self.x = left
	self.y = top
	self.width = width
	self.height = height
end function

Rect.setLTRB = function(left, top, right, bottom)
	self.x = left
	self.y = top
	self.width = right - left
	self.height = bottom - top
end function

Rect.MakeLTWH = function(left, top, width, height)
	r = new Rect
	r.x = left
	r.y = top
	r.width = width
	r.height = height
	return r
end function

Rect.MakeLTRB = function(left, top, right, bottom)
	r = new Rect
	r.x = left
	r.y = top
	r.width = right - left
	r.height = bottom - top
	return r
end function

Rect.fixInversion = function
	if self.width < 0 then
		self.x += self.width
		self.width = -self.width
	end if
	if self.height < 0 then
		self.y += self.height
		self.height = -self.height
	end if
end function

Rect.inset = function(dist)
	self.x += dist
	self.y += dist
	self.width -= dist*2
	self.height -= dist*2
end function

Rect.outset = function(dist)
	self.inset -dist
end function

Rect.overlaps = function(other)
	return self.right > other.left and self.left < other.right and
	  self.bottom > other.top and self.top < other.bottom
end function

Rect.contains = function(x, y)
	if y == null and x isa list then
		y = x[1]
		x = x[0]
	else if y == null and x isa map then
		y = x.y
		x = x.x
	end if
	return self.x <= x < self.x + self.width and
	       self.y <= y < self.y + self.height
end function

Rect.intersection = function(other)
	return Rect.MakeLTRB(min(self.right, other.x), min(self.bottom, other.y),
	  max(self.right, other.x), max(self.bottom, other.y))
end function

Rect.union = function(other)
	return Rect.MakeLTRB(min(self.x, other.x), min(self.y, other.y),
	  max(self.right, other.right), max(self.bottom, other.bottom))
end function
	
Rect.draw = function(color)
	if color == null then color = raylib.WHITE
	raylib.DrawRectangleRec self, color
end function

Rect.drawLines = function(color, lineThickness=1)
	if color == null then color = raylib.WHITE
	raylib.DrawRectangleLinesEx self, lineThickness, color
end function



return Rect