clear
import "Input"
import "mathUtil"

mt = @mathUtil.moveTowards

display(2).mode = displayMode.pixel

GFX = display(2)
SPD = display(4)

GFX.clear
SPD.clear

// test object
obj = new Sprite
obj.image = file.loadImage("/sys/pics/Rock.png")
obj.instances = []

obj.inWater = null
obj.targetY = null

obj.gravity = -165

obj.init = function
	SPD.sprites.push self
	self.x = mouse.x
	self.y = mouse.y

	self.inWater = false

	self.localBounds = new Bounds

	obj.instances.push self
end function

obj.update = function(dt)
	if self.inWater and self.targetY then
		self.y = mt(self.y, self.targetY, -self.gravity * dt)
	else
		self.y += self.gravity * dt
	end if
end function


waterPoint = {}
waterPoint.y = 0
waterPoint.velocity = 0
waterPoint.targetY = 0

water = {}
water.points = null

water.tension = 0.025
water.damp = 0.025
water.spread = 0.25

water.surfacePoints = 0

water.x = 0
water.y = 0
water.width = 0
water.height = 0
water.subdivide = 64

water.box = null

water.init = function(x=480, y=160, w=960, h=320)
	self.points = []

	self.x = x
	self.y = y
	self.width = w
	self.height = h

	//Surface
	// each point is going to be 32 pixels away form the previous one
	for i in range(0, w/self.subdivide)
		p = new waterPoint
		p.x = x + (-w/2 + self.subdivide * i)
		p.y = y + h/2
		p.targetY = y + h/2
	
		self.points.push p
	end for

	self.surfacePoints = self.points.len

	self.box = new Bounds
	self.box.x = x
	self.box.y = y
	self.box.width = w
	self.box.height = h

	//BottomCorners - TEMPORAL
	bLeft = new waterPoint
	bLeft.x = self.points[0].x
	bLeft.y = y - h/2

	bRight = new waterPoint
	bRight.x = self.points[-1].x
	bRight.y = y - h/2

	self.points.push bRight
	self.points.push bLeft
end function

water.update = function(dt)
	GFX.fillPoly self.points, color.rgba(100,100,255,150)

	for i in range(0, self.surfacePoints-1)
		wp = self.points[i]

		force = self.tension * (wp.targetY - wp.y)

		wp.velocity += force
		wp.velocity *= 1 - self.damp

		wp.y += wp.velocity * dt
	end for


	leftDeltas = [0] * self.surfacePoints
	rightDeltas = [0] * self.surfacePoints

	// Wave propagation
	for j in range(0, 7)
		for i in range(0, self.surfacePoints-1)
			if i > 0 then
				// current water point
				wp = self.points[i]

				// previus water point
				pwp = self.points[i - 1]

				diff = wp.y - pwp.y

				leftDeltas[i] = self.spread * diff

				pwp.velocity += leftDeltas[i]
			end if

			if i < self.surfacePoints-1 then
				// current water point
				wp = self.points[i]

				// next water point
				nwp = self.points[i + 1]

				diff = wp.y - nwp.y

				rightDeltas[i] = self.spread * diff

				nwp.velocity += rightDeltas[i]
			end if
		end for
	end for

	for ob in obj.instances
		if ob.inWater then continue

		if self.box.overlaps(ob.worldBounds) then
			ob.targetY = self.y + self.height / 2
			ob.inWater = true

			self.splashAt ob.x, -500
		end if
	end for

end function

water.splashAt = function(x, mag=-250)
	surfacePoint = (x - x % self.subdivide) / self.subdivide
	if surfacePoint < self.surfacePoints then
		self.points[surfacePoint].velocity += mag
	end if
end function

water.init

last = time
frameCount = 0
while not keyPressed("escape")
	frameCount += 1
	dt   = time - last
	last = time

	GFX.clear

	water.update dt


	if keyPressed("mouse 0") then
		o = new obj
		o.init
	end if

	for sp in SPD.sprites
		sp.update dt
	end for

	yield
end while

key.clear
