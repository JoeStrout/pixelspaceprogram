import "importUtil"
ensureImport "CircleCollider"
ensureImport "miscUtils"
ensureImport "Input"
ensureImport "orbit"
ensureImport "worldRenderer"

mu_planet = orbit.mu_planet

globals.Derp = new Sprite
Derp.image = file.loadImage("/usr/pics/derp.png")

Derp.inControl = true

// Srpite is 128 pixels
//I've set derp height to be around 3.2m
//Other wise it was to small to see even at 5m zoom
Derp.imageScale = 0.025
Derp.scale = 1
Derp.moveSpeed = 150
Derp.moveAccel = 15
Derp.moveFrict = 25

Derp.groundAccel = 20
Derp.groundFrict = 25

Derp.gravity = -850

Derp.airAccel = 4
Derp.airFrict = 2

Derp.jumpPower = 230

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
			self.vel[1] = self.jumpPower
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
			self.vel[0] = mathUtil.lerp(self.vel[0], xmov * self.moveSpeed, self.moveAccel * dt)
		else
			self.vel[0] = mathUtil.lerp(self.vel[0], 0, self.moveFrict * dt)
		end if


		if self.vel[0] != 0 or self.vel[1] != 0 then
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
				if (self.y - self.image.height * self.scale * 0.5) < closestPoint[1] and self.vel[1] < 0 then
					self.grounded = true
					self.y = closestPoint[1] + self.image.height * self.scale * 0.5
					self.vel[1] = 0
				end if
			end if

			pos = worldRenderer.screenToWorld(xyList(self))
			angle = worldRenderer.worldToScreen([0,0]).angleTo(pos)

			angledVel = [0, 0]
			angledVel[0] = self.vel[0]
			angledVel[1] = self.vel[1]

			self.rotation = -angle + 90

			// simple walking animation with rotation
			self.rotation += cos(time * 20) * 8 * xmov

			angledVel.rotate -angle+90

			self.x += angledVel[0] * dt
			self.y += angledVel[1] * dt
		end if
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

Derp.calculateScale = function(pixelScale)
	imgScale = self.imageScale / pixelScale
	if pixelScale <= 1 then
		self.scale = imgScale
	else
		self.scale = 1
		//self.image = derpIcon
	end if
end function