clear
import "Input"
import "mathUtil"
import "Vec2"
import "Circle"
import "Derp"
import "Rover"

Vec2 = Vec2.Vec2
Circle = Circle.Circle

GFX = display(5)
SPD = display(4)

GFX.clear
SPD.clear

gravity = -298.8

planet = new Circle
planet.init 480, 320, 200

bump = new Circle
bump.init 480, 150, 96

bump1 = new Circle
bump1.init 600, 360, 100

cols = [planet, bump, bump1]


r = new Rover.rover
r.x = 480; r.y = 580
r.init

d = new Derp.derp
d.x = 480; d.y = 580
d.init
d.rover = r

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
