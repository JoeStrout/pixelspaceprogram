import "importUtil"
ensureImport "CircleCollider"
ensureImport "miscUtils"
ensureImport "orbit"
ensureImport "worldRenderer"
ensureImport "LookupTable"

mu_planet = orbit.mu_planet

globals.Derp = new Sprite
Derp.image = file.loadImage("/usr/pics/derp.png")

Derp.inControl = true

Derp.walkAnim = dsl.anim.create(file.loadImage("/usr/pics/derpling_walking.png"), 128)
Derp.idleAnim = dsl.anim.create(file.loadImage("/usr/pics/derpling_idle.png"), 128)

Derp.currAnim = Derp.idleAnim

// Srpite is 128 pixels
//I've set derp height to be around 3.2m
//Other wise it was to small to see even at 5m zoom
Derp.imageScale = 0.025
Derp.scale = 1
Derp.moveSpeed = 25
Derp.moveAccel = 15
Derp.moveFrict = 25

Derp.lookDir = 1

Derp.groundAccel = 20
Derp.groundFrict = 25

Derp.gravity = -300
Derp.airAccel = 4
Derp.airFrict = 2

Derp.jumpPower = 50

Derp.grounded = false

Derp.xscale = 0.3
Derp.targetScale = 0.3

Derp.vel = [0, 0]
Derp.collider = null
Derp.rover = null
Derp.pos = [0, 0]

Derp.cols = []
Derp.planet = null

Derp.init = function(x, y, rad=18)
	self.x = x
	self.y = y

	self.vel = [0, 0]

	self.collider = new CircleCollider.Circle
	self.collider.init self.x, self.y, rad

	displays.outerSprites.sprites.push self
end function

Derp.update = function(dt, pixelScale)

	if self.inControl then
		xmov = key.axis("Horizontal")

		if self.grounded then
			self.moveAccel = self.groundAccel
			self.moveFrict = self.groundFrict
			self.vel[1] = 0

			if dsl.keyPressed("space") then
				self.vel[1] = self.jumpPower
			end if
		else
			self.moveAccel = self.airAccel
			self.moveFrict = self.airFrict

			self.vel[1] += self.gravity * dt
		end if

		if dsl.keyPressed("e") and self.rover then
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

			self.lookDir = sign(xmov)
		else
			self.vel[0] = mathUtil.lerp(self.vel[0], 0, self.moveFrict * dt)
		end if

		// Derp is moving
		if abs(self.vel[0]) > 15 then
			self.currAnim = self.walkAnim
		else
			self.currAnim = self.idleAnim
		end if

		closestPoint = [0, 0]

		//terrainX = []
		//for x in self.cols[1:-2]
		//	terrainX.push x[1]
		//end for
//
		//terrainLUT = LookupTable.Make(terrainX)
//
		//idx = terrainX.len * (self.x - terrainX[0]) / (terrainX[-1] - terrainX[0])
//
		//groundY = terrainLUT.lookup(idx)

		for i in range(45, 55)
			p = xyList(self)

			if closestPoint.len > 0 then
				currXDist = p.distanceTo(closestPoint)
				distToPoint = p.distanceTo(self.cols[i])

				if distToPoint < currXDist then
					closestPoint = self.cols[i]
				end if
			else
				closestPoint = self.cols[45]
			end if
		end for

		if closestPoint.len > 0 then
			groundY = closestPoint[1]
			if (self.y - self.image.height * self.scale[1] * 0.5) < groundY and self.vel[1] < 0 then
				self.grounded = true
				ty = groundY + self.image.height * self.scale[1] * 0.5
				self.y = mathUtil.lerp(self.y, ty, 25 *dt)
				self.vel[1] = 0
			else
				self.grounded = false
			end if
		end if

		pos = worldRenderer.screenToWorld(xyList(self))
		angle = worldRenderer.worldToScreen([0,0]).angleTo(pos)


		self.rotation = -angle + 90

		// Extra checks here to avoid calculations when not necesary

		if xmov != 0 then
			// simple walking animation with rotation
			self.rotation += cos(time * 20) * 8 * xmov
		end if

		angledVel = [0, 0]
		if self.vel[0] != 0 then angledVel[0] = self.vel[0]
		if self.vel[1] != 0 then angledVel[1] = self.vel[1]

		if angledVel[0] != 0 or angledVel[1] != 0 then
			angledVel.rotate -angle+90
		end if

		
		if angledVel[0] != 0 then self.x += angledVel[0] / pixelScale * dt
		if angledVel[1] != 0 then self.y += angledVel[1] / pixelScale * dt
	else
		if self.rover then
			self.vel[0] = 0
			self.vel[1] = 0
			self.x = self.rover.x
			self.y = self.rover.y

			self.rotation = self.rover.rotation

			if dsl.keyPressed("e") then
				self.inControl = true
				self.rover.inControl = false
			end if
		end if
	end if
	
	self.collider.x = self.x
	self.collider.y = self.y

	// Animate sprite
	dsl.anim.animate self, self.currAnim
end function

Derp.calculateScale = function(pixelScale)
	imgScale = self.imageScale / pixelScale
	if pixelScale <= 1 then
		self.scale = [imgScale * self.lookDir, imgScale]
	else
		self.scale = [1, 1]
		//self.image = derpIcon
	end if
end function