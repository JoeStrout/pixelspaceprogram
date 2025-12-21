import "Circle"

Circle = Circle.Circle

wheel = new Circle
wheel.grounded = null
wheel.body = null
wheel.pos = null

wheel.update = function(dt)
	self.pos = Vec2.fromClass(self)

	if self.body.inControl then
		self.vel.x = 2 * key.axis("Horizontal")
	else
		self.vel.x = 0
	end if

	if self.grounded then
		self.vel.y = 0
	else
		self.vel.y += gravity * dt
	end if

	angleToPlanet = self.pos.angleTo([planet.x, planet.y]) + 90

	angledVel = new Vec2
	angledVel.x = self.vel.x
	angledVel.y = self.vel.y
	angledVel.rotate angleToPlanet

	self.x += angledVel.x
	self.y += angledVel.y

	self.grounded = false
	for c in cols
		if self.checkCollition(c) then
			self.fixOverlap(c)
			self.grounded = true
			self.vel.y = 0
		end if
	end for

	//self.draw
end function

wheel.fixDistance = function(other)
	distance = self.pos.distanceTo([other.x, other.y])
	direction = self.pos.directionTo([other.x, other.y])

	desiredDist = 48
	minDist = 40

	if distance > desiredDist then
		diff = (distance - desiredDist) * 0.5

		self.pos.plus direction.times(0.5)
		//self.pos.x += direction.x * 0.5
		//self.pos.y += direction.y * 0.5
		
		other.pos.minus direction.times(0.5)
		//other.pos.x -= direction.x * 0.5
		//other.pos.y -= direction.y * 0.5

		self.x = mathUtil.lerp(self.x, self.pos.x, 10 * dt)
		self.y = mathUtil.lerp(self.y, self.pos.y, 10 * dt)

		other.x = mathUtil.lerp(other.x, other.pos.x, 10 * dt)
		other.y = mathUtil.lerp(other.y, other.pos.y, 10 * dt)

	else if distance < minDist then
		diff = (minDist - distance) * 0.5

		self.pos.x -= direction.x * 0.5
		self.pos.y -= direction.y * 0.5
		
		other.pos.x += direction.x * 0.5
		other.pos.y += direction.y * 0.5

		self.x = mathUtil.lerp(self.x, self.pos.x, 10 * dt)
		self.y = mathUtil.lerp(self.y, self.pos.y, 10 * dt)

		other.x = mathUtil.lerp(other.x, other.pos.x, 10 * dt)
		other.y = mathUtil.lerp(other.y, other.pos.y, 10 * dt)
	end if
end function

rover = new Sprite
rover.image = file.loadImage("./chasis.png")

rover.moveSpeed = 100
rover.moveAccel = 10
rover.moveFrict = 10

rover.inControl = false

rover.grounded = false

rover.vel = null
rover.collider = null

rover.vel = new Vec2
rover.scale = 0.15

rover.lp = new Vec2
rover.rp = new Vec2

rover.leftWheel = null
rover.rightWheel = null

rover.wheelMaxDist = 24
rover.wheelMinDist = 10
rover.wheelDesiredDist = 22

rover.init = function()
	self.collider = new Circle
	self.collider.init self.x, self.y, 24

	self.leftWheel = new wheel
	self.leftWheel.init self.x - 32, self.y - 16, 14

	self.rightWheel = new wheel
	self.rightWheel.init self.x + 32, self.y - 16, 14

	self.leftWheel.body = self
	self.rightWheel.body = self

	SPD.sprites.push self
	//self.tint = "#ffffff55"
end function

rover.update = function(dt)
	self.leftWheel.update dt
	self.rightWheel.update dt

	self.leftWheel.fixDistance(self.rightWheel)

	self.lp.x = self.x - 32
	self.lp.y = self.y - 16

	self.rp.x = self.x + 32
	self.rp.y = self.y - 16

	// Calculate wheels center
	lPos = Vec2.fromClass(self.leftWheel)
	rPos = Vec2.fromClass(self.rightWheel)

	wheelDist = lPos.distanceTo([rPos.x, rPos.y])
	wheelAngle = lPos.angleTo([rPos.x, rPos.y])

	self.rotation = wheelAngle

	vector = new Vec2
	vector.x = wheelDist * 0.5
	vector.rotate wheelAngle

	center = new Vec2
	center.x = self.leftWheel.x + vector.x
	center.y = self.leftWheel.y + vector.y

	pos = Vec2.fromClass(self)
	angleToPlanet = pos.angleTo([planet.x, planet.y])

	finalOffset = new Vec2
	finalOffset.x = -self.wheelDesiredDist
	finalOffset.rotate angleToPlanet

	finalPos = new Vec2
	finalPos.x = center.x + finalOffset.x
	finalPos.y = center.y + finalOffset.y

	self.x = finalPos.x
	self.y = finalPos.y

	self.collider.x = self.x
	self.collider.y = self.y
	//self.collider.draw
end function
