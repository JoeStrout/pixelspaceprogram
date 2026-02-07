// This module simulates spacecraft in freefall.

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

// Global list of all active SpaceObjects (including the player's Craft)
globals.spaceObjects = []

// SpaceObject: a physics-bearing object with an assembly, position, velocity,
// and orbit. Base class for Craft and any detached debris/stages.
globals.SpaceObject = {}
SpaceObject.assembly = null		// Assembly of parts
SpaceObject.pos = null			// [x,y] position in meters relative to planet
SpaceObject.vel = null			// [vx,vy] velocity in meters/sec
SpaceObject.angle = 0			// rotation angle in radians
SpaceObject.angVec = 0			// angular velocity, in radians/sec
SpaceObject.orbit = null
SpaceObject.mass = 1000
SpaceObject._cachedImage = null
SpaceObject.sprite = null		// Sprite for rendering (created lazily)
SpaceObject.launched = true		// debris is always "launched" (in free flight)
SpaceObject.crashed = false

SpaceObject.Make = function(assembly, pos, vel, angle=0)
	noob = new self
	noob.assembly = assembly
	noob.pos = pos[:]
	noob.vel = vel[:]
	noob.angle = angle
	noob.computeMass
	noob.updateOrbit
	return noob
end function

SpaceObject.image = function
	if self._cachedImage == null then
		self._cachedImage = self.assembly.getImage
		self._cachedImage.rotate -90
	end if
	return self._cachedImage
end function

SpaceObject.updateOrbit = function
	if self.orbit == null then self.orbit = new Orbit2D
	self.orbit.compute self.pos, self.vel, mu_planet
end function

SpaceObject.computeMass = function
	self.mass = 0
	for comp in self.assembly.components
		self.mass += comp.mass
	end for
end function

SpaceObject.update = function(dt)
	if self.crashed then return

	// Calculate gravity
	r = sqrt(self.pos[0]^2 + self.pos[1]^2)
	g = mu_planet / r^2
	gDir = [-self.pos[0], -self.pos[1]]
	gDir.normalize

	if self.launched then
		acc = [gDir[0] * g, gDir[1] * g]
	else
		acc = [0, 0]
	end if

	// Integrate to update state
	self.vel[0] += acc[0] * dt
	self.vel[1] += acc[1] * dt
	self.pos[0] += self.vel[0] * dt
	self.pos[1] += self.vel[1] * dt
	self.angle += self.angVec * dt

	// Check for ground collision
	upAngle = atan(self.pos.y, self.pos.x)
	groundR = worldRenderer.worldRadiusAtAngle(upAngle)
	alt = sqrt(self.pos.x^2 + self.pos.y^2) - groundR
	if self.launched and alt <= 0 then
		self.pos = self.pos.normalized.times(groundR)
		speed = self.vel.magnitude
		if speed > 20 then
			self.crashed = true
			return
		end if
		self.launched = false
	end if

	// Lock to orbit radius when coasting
	if self.orbit and self.orbit.isValid then
		orbitR = self.orbit.radiusAtGlobalAngle(atan(self.pos[1], self.pos[0]))
		currentR = sqrt(self.pos[0]^2 + self.pos[1]^2)
		factor = orbitR / currentR
		self.pos[0] *= factor; self.pos[1] *= factor
	end if
end function


// Craft: the player's spacecraft. Inherits from SpaceObject, adding
// throttle, staging, engine sound, and thrust physics.
globals.Craft = new SpaceObject
Craft.throttle = 0		// current throttle (0-1)
Craft.thrusting = false	// true when main engines actually burning
Craft.engineSound = engineSound
Craft.stages = null
Craft.alt = 0
Craft.speed = 0
Craft.groundR = 0
Craft.launched = false	// false: on launch pad; true: flyin' free

Craft.Make = function(assembly)
	craft = new self
	craft.assembly = assembly
	craft.pos = [0, 0]
	craft.vel = [0, 0]
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
	craft.computeMass
	globals.spaceObjects.push craft
	return craft
end function

Craft.update = function(dt)
	if self.crashed then return

	// Calculate gravity
	r = sqrt(self.pos[0]^2 + self.pos[1]^2)
	g = mu_planet / r^2
	gDir = [-self.pos[0], -self.pos[1]]
	gDir.normalize

	engineComp = null
	if self.throttle > 0 then
		// HACK for now: assume the last component is our engine,
		// and that corresponds to stage 1.
		if self.assembly.components[-1].partDef isa EngineDef then
			engineComp = self.assembly.components[-1]
			engineDef = engineComp.partDef	
			stageNum = 1
		end if
	end if
		
	if engineComp then	
		self.thrusting = true
		self.launched = true

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

		self.computeMass

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

	// Integrate to update state
	self.vel[0] += acc[0] * dt
	self.vel[1] += acc[1] * dt
	self.pos[0] += self.vel[0] * dt
	self.pos[1] += self.vel[1] * dt
	self.angle += self.angVec * dt

	// Store speed and altitude, and check for crashing into the ground
	self.upAngle = atan(self.pos.y, self.pos.x)
	self.groundR = worldRenderer.worldRadiusAtAngle(self.upAngle)
	self.alt = sqrt(self.pos.x^2 + self.pos.y^2) - self.groundR
	self.speed = self.vel.magnitude
	if self.launched and self.alt <= 0 then
		self.engineSound.stop
		self.pos = self.pos.normalized.times(self.groundR)
		if self.speed > 20 then
			self.crashed = true
			return
		end if
		self.launched = false	// landed!
	end if

	// If under thrust, update orbit; otherwise lock to orbit radius
	if self.thrusting then
		self.updateOrbit
		if not self.engineSound.isPlaying then self.engineSound.play
	else
		if self.engineSound.isPlaying then self.engineSound.stop
		if self.orbit and self.orbit.isValid then
			orbitR = self.orbit.radiusAtGlobalAngle(atan(self.pos[1], self.pos[0]))
			currentR = sqrt(self.pos[0]^2 + self.pos[1]^2)
			factor = orbitR / currentR
			self.pos[0] *= factor; self.pos[1] *= factor
		end if
	end if
end function

Craft.activateDecoupler = function(decouplerComp)
	newAsm = self.assembly.split(decouplerComp)
	if not newAsm then return null

	// Recenter both sub-assemblies and get their old COG offsets
	// (in component/pixel space, where +Y = nose direction).
	// Multiply by imageScale (0.1 m/pixel) to convert to meters.
	imgScale = 0.1  // meters per pixel (matches rocketRenderer.imageScale)
	shipOffset = self.assembly.recenter
	debrisOffset = newAsm.recenter
	origPos = self.pos[:]

	// Convert component-space offsets to world-space offsets.
	// Component +Y (nose) maps to world [cos(angle), sin(angle)]
	cosA = cos(self.angle); sinA = sin(self.angle)
	shipCx = shipOffset[0] * imgScale; shipCy = shipOffset[1] * imgScale
	debCx = debrisOffset[0] * imgScale; debCy = debrisOffset[1] * imgScale
	shipWorldDx = -shipCx * sinA + shipCy * cosA
	shipWorldDy =  shipCx * cosA + shipCy * sinA
	debrisWorldDx = -debCx * sinA + debCy * cosA
	debrisWorldDy =  debCx * cosA + debCy * sinA

	// Adjust ship world position
	self.pos[0] = origPos[0] + shipWorldDx
	self.pos[1] = origPos[1] + shipWorldDy

	// Create debris at its correct world position
	debrisPos = [origPos[0] + debrisWorldDx, origPos[1] + debrisWorldDy]
	debris = SpaceObject.Make(newAsm, debrisPos, self.vel, self.angle)

	// Add a small separation velocity along the nose axis
	sepSpeed = 2  // m/s
	fwd = [cosA, sinA]
	debris.vel[0] -= fwd[0] * sepSpeed
	debris.vel[1] -= fwd[1] * sepSpeed
	self.vel[0] += fwd[0] * sepSpeed * 0.1
	self.vel[1] += fwd[1] * sepSpeed * 0.1

	debris.updateOrbit
	self.updateOrbit

	globals.spaceObjects.push debris
	self._cachedImage = null
	self.computeMass

	return debris
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
