import "importUtil"
ensureImport "CircleCollider"
ensureImport "miscUtils"

derp = new Sprite
derp.image = file.loadImage("/pics/derp.png")

derp.inControl = true

derp.scale = 0.3

derp.moveSpeed = 100
derp.moveAccel = 10
derp.moveFrict = 10

derp.groundAccel = 10
derp.groundFrict = 15

derp.airAccel = 4
derp.airFrict = 2

derp.jumpPower = 130

derp.grounded = false

derp.xscale = 0.3
derp.targetScale = 0.3

derp.vel = []
derp.collider = null
derp.rover = null

derp.cols = []
derp.planet = null

derp.init = function(x, y, rad=18)
	self.vel = new Vec2
	self.x = x
	self.y = y

	self.collider = new CircleCollider.Circle
	self.collider.init self.x, self.y, rad

	display(4).sprites.push self
end function

derp.update = function(dt)
	if self.inControl then
		xmov = key.axis("Horizontal")

		if self.grounded then
			self.moveAccel = self.groundAccel
			self.moveFrict = self.groundFrict

		else
			self.moveAccel = self.airAccel
			self.moveFrict = self.airFrict

			self.vel[1] += gravity * dt
		end if

		if key.available then
			k = key.get

			if k == "space" then
				self.vel.y = self.jumpPower
			end if

			if k == "e" and self.rover then
				if self.collider.checkCollition(self.rover.collider) then
					self.inControl = false
					self.rover.inControl = true

					self.x = self.rover.x
					self.y = self.rover.y
					return
				end if
			end if
		end if

		if xmov then
			// simple flip animation
			self.xscale = mathUtil.moveTowards(self.xscale, self.targetScale * sign(xmov), 5 * dt)

			self.vel[0] = mathUtil.lerp(self.vel[0], xmov * self.moveSpeed, self.moveAccel * dt)
		else
			self.vel[0] = mathUtil.lerp(self.vel[0], 0, self.moveFrict * dt)
		end if

		self.scale = [self.xscale, self.targetScale]

		self.grounded = false
		for c in self.cols
			if self.collider.checkCollition(c) then
				self.collider.fixOverlap(c)

				self.x = self.collider.x
				self.y = self.collider.y

				self.grounded = true

				if self.vel[1] < 0 then self.vel[1] = 0
			end if
		end for

		angledVel = []
		angledVel[0] = self.vel[0]
		angledVel[1] = self.vel[1]

		if self.planet then
			pos = xyList(self)
			angleToPlanet = pos.angleTo([self.planet.x, self.planet.y])  + 90

			self.rotation = angleToPlanet

			// simple walking animation with rotation
			self.rotation += cos(time * 20) * 8 * xmov

			angledVel.rotate angleToPlanet
		end if

		self.x += angledVel[0] * dt
		self.y += angledVel[1] * dt
	else
		if self.rover then
			self.vel[0] = 0
			self.vel[1] = 0
			self.x = self.rover.x
			self.y = self.rover.y

			self.rotation = self.rover.rotation

			if keyPressed("e") then
				self.inControl = true
				self.rover.inControl = false
			end if
		end if
	end if

	self.collider.x = self.x
	self.collider.y = self.y
end function