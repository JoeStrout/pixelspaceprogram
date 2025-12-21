derp = new Sprite
derp.image = file.loadImage("./derp.png")

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

derp.vel = null
derp.collider = null
derp.rover = null

derp.init = function(rad=18)
	self.collider = new Circle
	self.collider.init self.x, self.y, rad

	self.vel = new Vec2

	SPD.sprites.push self
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

			self.vel.y += gravity * dt
		end if

		if keyPressed("space") then
			self.vel.y = self.jumpPower
		end if

		if keyPressed("e") then
			if self.collider.checkCollition(self.rover.collider) then
				self.inControl = false
				self.rover.inControl = true

				self.x = self.rover.x
				self.y = self.rover.y

				return
			end if
		end if

		if xmov then
			self.xscale = mathUtil.moveTowards(self.xscale, 0.3 * sign(xmov), 5 * dt)

			self.vel.x = mathUtil.lerp(self.vel.x, xmov * self.moveSpeed, self.moveAccel * dt)
		else
			self.vel.x = mathUtil.lerp(self.vel.x, 0, self.moveFrict * dt)
		end if

		self.scale = [self.xscale, 0.3]

		self.grounded = false
		for c in cols
			if self.collider.checkCollition(c) then
				self.collider.fixOverlap(c)

				self.x = self.collider.x
				self.y = self.collider.y

				self.grounded = true

				if self.vel.y < 0 then self.vel.y = 0
			end if
		end for

		pos = Vec2.fromClass(self)	
		angleToPlanet = pos.angleTo([planet.x, planet.y])  + 90

		self.rotation = angleToPlanet
		self.rotation += cos(time * 20) * 8 * xmov

		angledVel = new Vec2
		angledVel.x = self.vel.x
		angledVel.y = self.vel.y
		angledVel.rotate angleToPlanet

		self.x += angledVel.x * dt
		self.y += angledVel.y * dt
	else
		if self.rover then
			self.vel.x = 0
			self.vel.y = 0
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