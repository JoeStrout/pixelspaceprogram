// This module simulates a spacecraft in freefall.

import "importUtil"
ensureImport "orbit"
ensureImport "worldRenderer"

mu_planet = orbit.mu_planet

engineSound = function
	snd = new Sound
	snd.init 1, 1, 1, Sound.noiseWave
	snd.loop = true
	outer.engineSound = snd
	return snd
end function

globals.Craft = {}
Craft.mass = 1000		// craft mass, in kg
Craft.pos = null		// [x,y] position in meters relative to planet
Craft.vel = null		// [vx, vy] velocity in meters/sec
Craft.angle = 0			// rotation angle in radians
Craft.angVec = 0		// angular velocity, in radians/sec
Craft.thrustF = 0		// current thrust force (N), in direction we're facing
Craft.orbit = null
Craft.engineSound = engineSound

Craft.updateOrbit = function
	if self.orbit == null then self.orbit = new Orbit2D
	self.orbit.compute self.pos, self.vel, mu_planet
end function

Craft.update = function(dt)
	// calculate total acceleration (gravity plus thrust)
	r = sqrt(self.pos[0]^2 + self.pos[1]^2)
	g = mu_planet / r^2  // acceleration due to gravity, in m/sec^2
	gDir = [-self.pos[0], -self.pos[1]]
	gDir.normalize
	fwdDir = [cos(self.angle), sin(self.angle)]
	thrustAcc = self.thrustF / self.mass
	acc = [
		gDir[0] * g + fwdDir[0] * thrustAcc,
		gDir[1] * g + fwdDir[1] * thrustAcc ]
		
	
	// then integrate to update our state
	self.vel[0] += acc[0] * dt
	self.vel[1] += acc[1] * dt
	self.pos[0] += self.vel[0] * dt
	self.pos[1] += self.vel[1] * dt
	self.angle += self.angVec * dt
	
	// and if we're under thrust, update the orbit; otherwise,
	// lock to the orbit radius
	if self.thrustF then
		self.updateOrbit
		if not self.engineSound.isPlaying then self.engineSound.play
	else
		if self.engineSound.isPlaying then self.engineSound.stop
		orbitR = self.orbit.radiusAtGlobalAngle(atan(self.pos[1], self.pos[0]))
		currentR = sqrt(self.pos[0]^2 + self.pos[1]^2)
		factor = orbitR / currentR
		self.pos[0] *= factor; self.pos[1] *= factor
	end if
end function

drawInfo = function(craft)
	text.clear
	alt = sqrt(craft.pos.x^2 + craft.pos.y^2) - 6000*km // (radius of planet)
	altStr = "000000" + str(round(alt/1000, 3)) + "000"
	dotPos = altStr.indexOf(".")
	altStr = altStr[dotPos-6:dotPos+4]
	text.row = 25; text.column = 25; print "ALT: " + altStr + "km"
	text.row = 0; text.column = 55; print "SPEED: " + timeScale + "X", ""
end function

timeScale = 8

demo = function
	clear
	globals.ship = new Craft

	// start in a 10,000 km (radius) roughly circular orbit above the planet
	alt = 10000*km
	speed = 8400 // 6300  // (m/sec)

	ship.pos = [0, alt]
	ship.vel = [-speed, 0]
	ship.angle = pi
	ship.updateOrbit

	worldRenderer.setup
	worldRenderer.refScreenPos = [480,320]
	worldRenderer.zoomToScaleIdx 11

	display(2).mode = displayMode.pixel
	display(2).clear
	display(2).print "Thrust:         shift", 10, 50, color.silver, "small"
	display(2).print "Rotate ship:    ← →", 10, 35, color.silver, "small"
	display(2).print "Zoom in/out:    + -", 10, 20, color.silver, "small"
	display(2).print "Time fast/slow: . ,", 10, 5, color.silver, "small"

	while true
		yield
		// check inputs
		if key.pressed("left shift") or key.pressed("right shift") then
			ship.thrustF = 5000  // Apollo service module ~= 91 kN
		else
			ship.thrustF = 0
		end if
		if key.available then
			k = key.get
			if k == "." and timeScale < 256 then
				globals.timeScale *= 2
			else if k == "," and timeScale > 1 then
				globals.timeScale /= 2
			else if k == "+" or k == "=" then
				worldRenderer.zoomIn
			else if k == "-" or k == "_" then
				worldRenderer.zoomOut
			end if
		end if
		// Rotation is tricky -- if we simulate this realistically, while the
		// time scale is 10X or more, it's completely uncontrollable!  So for
		// now let's ignore reality and let the player control the dang thing.
		if key.pressed("left") then	// to do: better rotational physics
			ship.angle += pi/60
		else if key.pressed("right") then
			ship.angle -= pi/60
		end if
		
		if key.pressed("escape") then break
		
		// update simulation
		ship.update timeScale/60
		
		// update rocket display
		worldRenderer.rocketSprite.rotation = ship.angle * 180/pi	
		worldRenderer.rocketPos = ship.pos
		worldRenderer.update
		worldRenderer.drawOrbit ship.orbit
		
		//drawInfo ship
	end while
	key.clear
end function

if locals == globals then demo
