// This module simulates a spacecraft in freefall.

import "importUtil"
ensureImport "orbit"
ensureImport "worldRenderer"
ensureImport "assembly"

mu_planet = orbit.mu_planet

engineSound = function
	snd = new Sound
	snd.init 1, 1, 1, Sound.noiseWave
	snd.loop = true
	outer.engineSound = snd
	return snd
end function

globals.StageType = {}
StageType.NONE = "NONE"
StageType.ENGINE = "ENGINE"
StageType.DECOUPLER = "DECOUPLER"
StageType.CHUTES = "CHUTES"

// Stage: represents a triggerable part of a spacecraft, that may either
// represent a set of engines, a decoupler, parachutes, or whatever.
// Each stage has a corresponding panel in the cockpit UI.
globals.Stage = {}
Stage.type = StageType.NONE

Stage.Make = function(type)
	noob = new self
	noob.type = type
	if type == StageType.ENGINE then noob.fuelPct = 100
	return noob
end function

// Craft: represents the whole spacecraft.
globals.Craft = {}
Craft.assembly = null	// Assembly of parts comprising this craft
Craft.mass = 1000		// craft mass, in kg
Craft.pos = null		// [x,y] position in meters relative to planet
Craft.vel = null		// [vx, vy] velocity in meters/sec
Craft.angle = 0			// rotation angle in radians
Craft.angVec = 0		// angular velocity, in radians/sec
Craft.throttle = 0		// current throttle (0-1)
Craft.thrusting = false // true when main engines actually burning
Craft.orbit = null
Craft.engineSound = engineSound
Craft._cachedImage = null
Craft.stages = null
Craft.alt = 0
Craft.speed = 0
Craft.groundR = 0
Craft.launched = false	// false: on launch pad; true: flyin' free
Craft.crashed = false	// true: kaboom

Craft.Make = function(assembly)
	craft = new self
	craft.assembly = assembly
	// For now, hard-coding the stages; ToDo: calculate from assembly
	craft.stages = [null]
	for i in range(1,8)
		if i == 1 then
			craft.stages.push Stage.Make(StageType.ENGINE)
		else if i == 2 then
			craft.stages.push Stage.Make(StageType.DECOUPLER)
		else
			craft.stages.push Stage.Make(StageType.NONE)
		end if
	end for
	return craft
end function

Craft.image = function
	if self._cachedImage == null then
		self._cachedImage = self.assembly.getImage
		self._cachedImage.rotate -90
	end if
	return self._cachedImage
end function

Craft.updateOrbit = function
	if self.orbit == null then self.orbit = new Orbit2D
	self.orbit.compute self.pos, self.vel, mu_planet
end function

Craft.update = function(dt)
	if self.crashed then
		// ToDo: update explosion effects?
		return
	end if
	
	// calculate total acceleration (gravity plus thrust)
	r = sqrt(self.pos[0]^2 + self.pos[1]^2)
	g = mu_planet / r^2  // acceleration due to gravity, in m/sec^2
	gDir = [-self.pos[0], -self.pos[1]]
	gDir.normalize
	
	if self.throttle > 0 then
		self.thrusting = true
		self.launched = true
		
		// HACK for now: assume component 0 is our engine,
		// and that corresponds to stage 1.
		engineComp = self.assembly.components[0]
		engineDef = engineComp.partDef
		qa.assert engineDef isa EngineDef
		stageNum = 1
		
		// Also HACK for now: assume 0.5 atm pressure
		atmPressure = 0.5
		
		thrustN = engineDef.thrust(self.throttle, atmPressure)
		engineComp.fuelMass -= engineDef.massFlow * self.throttle * dt
		if engineComp.fuelMass < 0 then
			engineComp.fuelMass = 0
			thrustN = 0
			self.thrusting = false
		else
			ship.stages[stageNum].fuelPct = engineComp.fuelPct
			cockpitUI.drawStagePanel stageNum
		end if		
		
		self.mass = 0
		for comp in self.assembly.components
			self.mass += comp.mass
		end for
		
		fwdDir = [cos(self.angle), sin(self.angle)]
		thrustAcc = thrustN / self.mass
		acc = [
			gDir[0] * g + fwdDir[0] * thrustAcc,
			gDir[1] * g + fwdDir[1] * thrustAcc ]
	else if self.launched then
		self.thrusting = false
		acc = [gDir[0] * g, gDir[1] * g]
	else
		// still on launch pad, all's quiet
		self.thrusting = false
		acc = [0, 0]
	end if
	
	// then integrate to update our state
	self.vel[0] += acc[0] * dt
	self.vel[1] += acc[1] * dt
	self.pos[0] += self.vel[0] * dt
	self.pos[1] += self.vel[1] * dt
	self.angle += self.angVec * dt
	
	// store speed and altitude, and check for crashing into the ground
	self.upAngle = atan(self.pos.y, self.pos.x)
	self.groundR = worldRenderer.worldRadiusAtAngle(self.upAngle)
	self.alt = sqrt(self.pos.x^2 + self.pos.y^2) - self.groundR
	self.speed = ship.vel.magnitude
	if self.launched and self.alt <= 0 then
		self.engineSound.stop
		self.pos = self.pos.normalized.times(self.groundR)
		if self.speed > 20 then
			self.crashed = true
			return
		end if
		self.launched = false	// landed!
	end if

	// and if we're under thrust, update the orbit; otherwise,
	// lock to the orbit radius
	if self.thrusting then
		self.updateOrbit
		if not self.engineSound.isPlaying then self.engineSound.play
	else
		if self.engineSound.isPlaying then self.engineSound.stop
		if self.orbit.isValid then
			orbitR = self.orbit.radiusAtGlobalAngle(atan(self.pos[1], self.pos[0]))
			currentR = sqrt(self.pos[0]^2 + self.pos[1]^2)
			factor = orbitR / currentR
			self.pos[0] *= factor; self.pos[1] *= factor
		end if
	end if
end function

drawInfo = function(craft, timeScale)
	text.clear
	if craft.crashed then
		text.row = 13; text.column = 30; print "BOOM!!!"
	end if

	altStr = "000000" + str(abs(round(craft.alt/1000, 3))) + "000"
	dotPos = altStr.indexOf(".")
	altStr = altStr[dotPos-6:dotPos+4]
	if craft.alt < 0 then altStr = "-" + altStr[1:]
	text.row = 25; text.column = 25; print "ALT: " + altStr + " km"
	speedStr = "000000" + str(round(craft.speed, 3)) + "000"
	dotPos = speedStr.indexOf(".")
	speedStr = speedStr[dotPos-6:dotPos+4]
	text.row = 24; text.column = 25; print "SPD: " + speedStr + " m/s"
	text.row = 0; text.column = 52; 
	if timeScale > 0 then
		print "TIME WARP: " + timeScale + "X", ""
	else
		print "TIME PAUSED", ""
	end if
end function

demo = function
	clear
	globals.ship = Craft.Make(Assembly.standardTestRocket)
	timeScale = 8

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
			ship.throttle = 1
		else
			ship.throttle = 0
		end if
		if key.available then
			k = key.get
			if (k == "." or k == ">") and timeScale < 256 then
				if timeScale > 0 then globals.timeScale *= 2 else globals.timeScale = 1
				print "timeScale: " + timeScale
			else if k == "," or k == "<" then
				if timeScale > 1 then globals.timeScale /= 2 else globals.timeScale = 0
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
		
		drawInfo ship, timeScale
	end while
	key.clear
end function

if locals == globals then demo
