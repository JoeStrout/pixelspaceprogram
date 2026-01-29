import "CircleCollider"
import "miscUtils"
import "worldRenderer"
import "mathUtil"

rover = new Sprite
rover.image = file.loadImage("/usr/pics/chasis.png")

rover.moveSpeed = 50
rover.moveAccel = 10
rover.moveFrict = 10

rover.inControl = false

rover.grounded = false
rover.imageScale = 0.025
rover.vel = null
rover.collider = null

rover.vel = [0,0]
rover.scale = 0.15

rover.lp = [0,0]
rover.rp = [0,0]

rover.cols = []
rover.radius = 14
rover.prevRotation = rover.rotation

rover.init = function
	self.collider = new CircleCollider.Circle
	self.collider.init self.x, self.y, 24

	displays.outerSprites.sprites.push self

	yoff = self.image.height * self.scale * 0.5

	self.lp = [-64, yoff]
	self.rp = [64, yoff]
end function

rover.update = function(dt, pixelScale)
	if self.inControl then
		xmov = key.axis("Horizontal")

		if xmov then
			self.vel[0] = mathUtil.lerp(self.vel[0], xmov * self.moveSpeed, self.moveAccel * dt)
		else
			self.vel[0] = mathUtil.lerp(self.vel[0], 0, self.moveFrict * dt)
		end if
	end if

	if not self.grounded then self.vel[1] += -1550 * dt
	
	if self.prevRotation != self.rotation then
		self.prevRotation = self.rotation

		self.lp.rotate self.rotation
		self.rp.rotate self.rotation
	end if

	leftPoint = [self.x + self.lp[0], self.y + self.lp[1]]
	rightPoint = [self.x + self.rp[0], self.y + self.rp[1]]
	
	closeL = []
	closeR = []

	for i in range(45, 55)
		if i == 45 then
			closeL = self.cols[i]
			closeR = self.cols[i]
		else
			// Checking left point first
			currXDist = leftPoint.distanceTo(closeL)
			distToPoint = leftPoint.distanceTo(self.cols[i])

			if distToPoint < currXDist then
				closeL = self.cols[i]
			end if

			// Now right point
			currXDist = rightPoint.distanceTo(closeR)
			distToPoint = rightPoint.distanceTo(self.cols[i])

			if distToPoint < currXDist then
				closeR = self.cols[i]
			end if
		end if
	end for

	leftY = self.y
	leftGround = false
	rightGround = false

	if (self.y - self.image.height * self.scale * 0.5) < closeL[1] and self.vel[1] < 0 then
		leftY = closeL[1] + self.image.height * self.scale * 0.5
		leftGround = true
	end if

	rightY = self.y

	if (self.y - self.image.height * self.scale * 0.5) < closeR[1] and self.vel[1] < 0 then
		rightY = closeR[1] + self.image.height * self.scale * 0.5
		rightGround = true
	end if

	self.y = mathUtil.lerp(self.y, leftY - (leftY - rightY) * 0.5 - 2, 25 * dt)
	self.rotation = closeL.angleTo(closeR)

	if leftGround and rightGround then
		self.vel[1] = 0
	end if

	pos = worldRenderer.screenToWorld(xyList(self))
	angle = worldRenderer.worldToScreen([0,0]).angleTo(pos)

	angledVel = [0, 0]
	if self.vel[0] != 0 then angledVel[0] = self.vel[0]
	if self.vel[1] != 0 then angledVel[1] = self.vel[1]

	if angledVel[0] != 0 or angledVel[1] != 0 then
		angledVel.rotate -angle+90
	end if

	
	if angledVel[0] != 0 then self.x += angledVel[0] / pixelScale * dt
	if angledVel[1] != 0 then self.y += angledVel[1] / pixelScale * dt

	self.collider.x = self.x
	self.collider.y = self.y
end function

rover.calculateScale = function(pixelScale)
	imgScale = self.imageScale / pixelScale
	if pixelScale <= 1 then
		self.scale = imgScale
	else
		self.scale = 1
		//self.image = derpIcon
	end if
end function