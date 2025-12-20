clear
import "Input"
import "mathUtil"
import "Vec2"
import "Circle"

mt = @mathUtil.moveTowards

Vec2 = Vec2.Vec2

GFX = display(5)
SPD = display(4)

GFX.clear
SPD.clear

maxWheelDist = 96
minWheelDist = 96

gravity = -298.8

planet = new Circle.Circle
planet.init 480, 320, 200

bump = new Circle.Circle
bump.init 480, 150, 64

bump1 = new Circle.Circle
bump1.init 600, 360, 100

cols = [planet, bump, bump1]

derp = new Sprite
derp.image = file.loadImage("./derp.png")

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

derp.init = function(rad=18)
	self.collider = new Circle.Circle
	self.collider.init self.x, self.y, rad

	self.vel = new Vec2

	SPD.sprites.push self
end function

derp.update = function(dt)
	
	if self.grounded then
		self.moveAccel = self.groundAccel
		self.moveFrict = self.groundFrict

	else
		self.moveAccel = self.airAccel
		self.moveFrict = self.airFrict

		self.vel.y += gravity * dt
	end if

	xmov = key.axis("Horizontal")

	if xmov then
		self.xscale = mathUtil.moveTowards(self.xscale, 0.3 * sign(xmov), 5 * dt)

		self.vel.x = mathUtil.lerp(self.vel.x, xmov * self.moveSpeed, self.moveAccel * dt)
	else
		self.vel.x = mathUtil.lerp(self.vel.x, 0, self.moveFrict * dt)
	end if


	self.scale = [self.xscale, 0.3]

	if keyPressed("space") then
		self.vel.y = self.jumpPower
	end if

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

	self.collider.x = self.x
	self.collider.y = self.y
end function

d = new derp
d.x = 480; d.y = 580
d.init

last = time
frameCount = 0
while not keyPressed("escape")
	frameCount += 1
	dt = time - last
	last = time


	GFX.clear

	for c in cols
		c.draw
	end for

	for sp in SPD.sprites
		sp.update dt
	end for

	yield
end while

key.clear
