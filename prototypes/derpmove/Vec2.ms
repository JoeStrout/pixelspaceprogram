Vec2 = new {}
Vec2.x = 0
Vec2.y = 0

Vec2.fromClass = function(cls)
	v = new Vec2
	v.x = cls.x
	v.y = cls.y

	return v
end function

Vec2.normalize = function 
	length = self.magnitude
	if length != 0 then
		self.x /= length
		self.y /= length
	else
		self.x = 0
		self.y = 0
	end if
end function

Vec2.magnitude = function
	return sqrt(self.x * self.x + self.y * self.y)
end function

Vec2.distanceTo = function(v2)
	if v2 isa list then
		dx = v2[0] - self.x
		dy = v2[1] - self.y
	else
		dx = v2.x - self.x
		dy = v2.y - self.y
	end if
	return sqrt(dx * dx + dy * dy)
end function

Vec2.minus = function(v2)
	if v2 isa list then
		self.x -= v2[0]
		self.y -= v2[1]
	else
		self.x -= v2.x
		self.y -= v2.y
	end if

	return self
end function

Vec2.plus = function(v2)
	if v2 isa list then
		self.x += v2[0]
		self.y += v2[1]
	else
		self.x += v2.x
		self.y += v2.y
	end if
	
	return self
end function

Vec2.times = function(v2)
	if v2 isa list then
		self.x *= v2[0]
		self.y *= v2[1]
	else if v2 isa number then
		self.x *= v2
		self.y *= v2
	else
		self.x *= v2.x
		self.y *= v2.y
	end if
	
	return self
end function

Vec2.directionTo = function(v2)
	d = new Vec2
	if v2 isa list then
		d.x = v2[0] - self.x
		d.y = v2[1] - self.y
	else
		d.x = v2.x - self.x
		d.y = v2.y - self.y
	end if
	d.normalize

	return d
end function

Vec2.dot = function(v2)
	if v2 isa list then
		return self.x * v2[0] + self.y * v2[1]
	else
		return self.x * v2.x + self.y * v2.y
	end if
end function

Vec2.angleTo = function(v2)
	if v2 isa list then
		angle = atan((v2[1] - self.y), (v2[0] - self.x)) * (180/pi)
		return angle
	else
		angle = atan((v2.x - self.y), (v2.y - self.x)) * (180/pi)
		return angle
	end if
end function

Vec2.rotate = function(angle)
	deg2rad = pi / 180
	cosA = cos(angle * deg2rad)
	sinA = sin(angle * deg2rad)
	
	x = self.x * cosA - self.y * sinA
	y = self.x * sinA + self.y * cosA
	
	self.x = x
	self.y = y
end function