import "mathUtil"

Circle = new {}
Circle.x = 0
Circle.y = 0
Circle.mass = 1
Circle.radius = 32

Circle.vel = null

Circle.init = function(x, y, r=64)
	self.x = x
	self.y = y
	self.radius = r

	self.vel = new Vec2
end function

Circle.checkCollition = function(c)
	pos = Vec2.fromClass(self)
	cPos = Vec2.fromClass(c)

	delta = cPos.minus(pos)
	dist = delta.magnitude
	minDist = self.radius + c.radius
	
	return dist < minDist 
end function

Circle.fixOverlap = function(c, both=false)
	pos = Vec2.fromClass(self)
	cPos = Vec2.fromClass(c)

	delta = cPos.minus(pos)
	dist = delta.magnitude
	minDist = self.radius + c.radius

	n = delta.times(1 / dist)
	overlap = minDist - dist

	correction = n.times(overlap * 0.5)

	if both then
		pos.minus(correction)
		cPos.plus(correction)

		self.x = pos.x
		self.y = pos.y
		c.x = cPos.x
		c.y = cPos.y
	else
		pos.minus(correction.times(2))
		
		self.x = pos.x
		self.y = pos.y
	end if
end function

Circle.draw = function(disp=5)
	display(disp).drawEllipse(
		self.x - self.radius, self.y - self.radius,
		self.radius * 2, self.radius * 2,
		"#55dd22", 1)
end function
