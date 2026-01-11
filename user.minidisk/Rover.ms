import "CircleCollider"
import "miscUtils"
import "worldRenderer"

wheel = new CircleCollider.Circle
wheel.grounded = null
wheel.body = null
wheel.pos = null
wheel.cols = null
wheel.vel = null

wheel.gravity = -1050

wheel.init = function(x, y, rad)

 	//self.x - 32, self.y - 16, 14
 	self.x = x
 	self.y = y

 	self.radius = rad

	self.pos = xyList(self)
	self.vel = [0,0]
	self.cols = []
end function

wheel.update = function(dt)

	if self.body.inControl then
		self.vel[0] = 2 * key.axis("Horizontal")
	else
		self.vel[0] = 0
	end if

	if self.grounded then
		self.vel[1] = 0
	else
		self.vel[1] += self.gravity * dt
	end if

	if self.vel[0] != 0 or self.vel[1] != 0 and self.cols.len > 0 then

		self.grounded = false
		closestPoint = []
		for i in range(0, self.cols.len-1)
			if i == 0 then
				closestPoint = self.cols[i]
			else
				p = xyList(self)

				currXDist = p.distanceTo(closestPoint)
				distToPoint = p.distanceTo(self.cols[i])

				if distToPoint < currXDist then
					closestPoint = self.cols[i]
				end if
			end if
		end for

		if closestPoint.len > 1 then
			if (self.y - self.radius) < closestPoint[1] and self.vel[1] < 0 then
				self.grounded = true
				self.y = closestPoint[1] + self.radius
				self.vel[1] = 0
			end if
		end if

		pos = worldRenderer.screenToWorld(xyList(self))
		angle = worldRenderer.worldToScreen([0,0]).angleTo(pos)

		angledVel = [0,0]
		angledVel[0] = self.vel[0]
		angledVel[1] = self.vel[1]
		angledVel.rotate -angle + 90

		self.x += angledVel.x * dt 
		self.y += angledVel.y * dt
	end if
	//self.draw
end function

wheel.fixDistance = function(other)
	distance = self.pos.distanceTo([other.x, other.y])
	direction = self.pos.minus(other)

	desiredDist = 48
	minDist = 40

	if distance > desiredDist then
		diff = (distance - desiredDist) * 0.5

		self.pos.plus direction.times(0.5)
		
		other.pos.minus direction.times(0.5)

		self.x = mathUtil.lerp(self.x, self.pos[0], 10 * dt)
		self.y = mathUtil.lerp(self.y, self.pos[1], 10 * dt)

		other.x = mathUtil.lerp(other.x, other.pos[0], 10 * dt)
		other.y = mathUtil.lerp(other.y, other.pos[1], 10 * dt)

	else if distance < minDist then
		diff = (minDist - distance) * 0.5

		self.pos[0] -= direction[0] * 0.5
		self.pos[1] -= direction[1] * 0.5
		
		other.pos[0] += direction[0] * 0.5
		other.pos[1] += direction[1] * 0.5

		self.x = mathUtil.lerp(self.x, self.pos[0], 10 * dt)
		self.y = mathUtil.lerp(self.y, self.pos[0], 10 * dt)

		other.x = mathUtil.lerp(other.x, other.pos[1], 10 * dt)
		other.y = mathUtil.lerp(other.y, other.pos[1], 10 * dt)
	end if
end function

rover = new Sprite
rover.image = file.loadImage("/usr/pics/chasis.png")

rover.moveSpeed = 250
rover.moveAccel = 10
rover.moveFrict = 10

rover.inControl = false

rover.grounded = false

rover.vel = null
rover.collider = null

rover.vel = [0,0]
rover.scale = 0.15

rover.lp = [0,0]
rover.rp = [0,0]

rover.leftWheel = null
rover.rightWheel = null

rover.wheelMaxDist = 24
rover.wheelMinDist = 10
rover.wheelDesiredDist = 22

rover.init = function
	self.collider = new CircleCollider.Circle
	self.collider.init self.x, self.y, 24

	self.leftWheel = new wheel
	self.leftWheel.init self.x - 32, self.y - 16, 14

	self.rightWheel = new wheel
	self.rightWheel.init self.x + 32, self.y - 16, 14

	self.leftWheel.body = self
	self.rightWheel.body = self

	display(4).sprites.push self
	//self.tint = "#ffffff55"
end function

rover.update = function(dt)
	self.leftWheel.update dt
	self.rightWheel.update dt

	self.leftWheel.fixDistance(self.rightWheel)

	self.lp[0] = self.x - 32
	self.lp[1] = self.y - 16

	self.rp[0] = self.x + 32
	self.rp[1] = self.y - 16

	// Calculate wheels center
	lPos = xyList(self.leftWheel)
	rPos = xyList(self.rightWheel)

	wheelDist = lPos.distanceTo(rPos)
	wheelAngle = lPos.angleTo(rPos)

	self.rotation = wheelAngle

	vector = [wheelDist * 0.5, 0]
	vector.rotate wheelAngle

	center = [self.leftWheel[0] + vector[0], self.leftWheel[1] + vector[1]]

	pos = worldRenderer.screenToWorld(xyList(self))
	angle = worldRenderer.worldToScreen([0,0]).angleTo(pos)

	finalOffset = [-self.wheelDesiredDist,0]
	finalOffset.rotate angleToPlanet

	finalPos = [center[0] + finalOffset[0], center[1] + finalOffset[1]]

	self.x = finalPos[0]
	self.y = finalPos[1]

	self.collider.x = self.x
	self.collider.y = self.y
	//self.collider.draw
end function
