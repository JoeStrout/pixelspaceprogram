import "importUtil"
ensureImport "CircleCollider"
ensureImport "miscUtils"
ensureImport "Input"

globals.Derp = new Sprite
Derp.image = file.loadImage("../pics/derp.png")

Derp.inControl = true

Derp.scale = 0.3

Derp.moveSpeed = 100
Derp.moveAccel = 10
Derp.moveFrict = 10

Derp.groundAccel = 10
Derp.groundFrict = 15

Derp.gravity = 0//-9.8

Derp.airAccel = 4
Derp.airFrict = 2

Derp.jumpPower = 130

Derp.grounded = false

Derp.xscale = 0.3
Derp.targetScale = 0.3

Derp.vel = [0, 0]
Derp.collider = null
Derp.rover = null

Derp.cols = []
Derp.planet = null

Derp.init = function(x, y, rad=18)
	self.x = x
	self.y = y

	self.vel = [0, 0]

	self.collider = new CircleCollider.Circle
	self.collider.init self.x, self.y, rad

	display(4).sprites.push self
end function

Derp.update = function(dt)
	if self.inControl then
		xmov = key.axis("Horizontal")

		if self.grounded then
			self.moveAccel = self.groundAccel
			self.moveFrict = self.groundFrict

		else
			self.moveAccel = self.airAccel
			self.moveFrict = self.airFrict

			self.vel[1] += self.gravity * dt
		end if

		if Input.keyPressed("space") then
			print "Jump"
			self.vel.y = self.jumpPower
		end if

		if Input.keyPressed("e") and self.rover then
			if self.collider.checkCollition(self.rover.collider) then
				self.inControl = false
				self.rover.inControl = true

				self.x = self.rover.x
				self.y = self.rover.y
				return
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

		angledVel = [0, 0]
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