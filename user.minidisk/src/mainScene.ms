// This is the main game scene, presenting an external view of the spacecraft
// and/or explorer character.  This is where you fly (and may also be where
// you walk around, though we should probably separate as much of the EVA code
// into a separate module as we can).

import "importUtil"
ensureImport "stringUtil"
ensureImport "assembly"
ensureImport "spacecraft"
ensureImport "gameData"
ensureImport "worldRenderer"
ensureImport "cockpitUI"
ensureImport "DSL"

// nextStageNum: tracks which stage to fire next (counts down or up as stages fire)
globals.nextStageNum = 2  // start at stage 2 (decoupler); stage 1 (engine) is auto

// findDecouplerComponent: find a component in the ship assembly that acts as
// a decoupler. For now, we look for any component whose partDef key contains
// "decoupler" (case-insensitive). Returns the component, or null.
findDecouplerComponent = function
	for comp in ship.assembly.components
		if comp.partDef.key.lower.contains("decoupler") then return comp
	end for
	return null
end function

// fireNextStage: activate the next stage in the staging sequence.
fireNextStage = function
	print "fireNextStage (" + nextStageNum + ")"
	if nextStageNum > 8 then return
	stage = ship.stages[nextStageNum]
	if stage.type == StageType.DECOUPLER then
		decComp = findDecouplerComponent
		if decComp then
			ship.activateDecoupler decComp
			stage.type = StageType.NONE  // mark as spent
			cockpitUI.drawStagePanel nextStageNum
		else
			print "No decoupler found"
		end if
	else
		print "Nothing to do for " + stage.type + " stage"
	end if
	globals.nextStageNum += 1
	cockpitUI.drawStagePanel nextStageNum - 1
	cockpitUI.drawStagePanel nextStageNum
end function

setup = function
	displays.setup
	cockpitUI.init
	globals.spaceObjects = []  // reset before creating ship
	globals.ship = Craft.Make(assembly.standardTestRocket)

	if false then
		// start in a 10,000 km (radius) roughly circular orbit above the planet
		alt = 10000*km
		speed = 8400 // 6300  // (m/sec)

		ship.pos = [0, alt]
		ship.vel = [-speed, 0]
		ship.angle = pi
	else
		// start the rocket on the launch pad, at rest
		ship.pos = [0, worldRenderer.worldRadiusAtAngle(pi/2)+25]
		ship.vel = [0, 0]
		ship.angle = pi/2
	end if

	ship.updateOrbit

	worldRenderer.setup
	worldRenderer.refScreenPos = [370,320]
	worldRenderer.zoomToScaleIdx 3

	cockpitUI.draw

	displays.hud.print "Thrust:         shift", 10, 85, color.silver, "small"
	displays.hud.print "Rotate ship:    ← →", 10, 70, color.silver, "small"
	displays.hud.print "Zoom in/out:    + -", 10, 55, color.silver, "small"
	displays.hud.print "Rotate view:    [ ]", 10, 40, color.silver, "small"
	displays.hud.print "Time fast/slow: . ,", 10, 25, color.silver, "small"
	displays.hud.print "Stage (decouple): space", 10, 10, color.silver, "small"

	globals.timeScale = 1
	globals.nextStageNum = 2
end function

mainLoop = function
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
			if k == " " then
				fireNextStage
			else if (k == "." or k == ">") and timeScale < 256 then
				if timeScale > 0 then globals.timeScale *= 2 else globals.timeScale = 1
				cockpitUI.drawTimeScale timeScale
			else if k == "," or k == "<" then
				if timeScale > 1 then globals.timeScale /= 2 else globals.timeScale = 0
				cockpitUI.drawTimeScale timeScale
			else if k == "+" or k == "=" then
				worldRenderer.zoomIn
			else if k == "-" or k == "_" then
				worldRenderer.zoomOut
			else if k == "[" or k == "{" then
				worldRenderer.camera.rotate 15
			else if k == "]" or k == "}" then
				worldRenderer.camera.rotate -15
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

		if key.pressed("p") then
			text.print displays.hudSprites.sprites
		end if

		if key.pressed("escape") then break

		// update simulation for all space objects
		if timeScale > 0 then
			dt = timeScale/60
			for obj in spaceObjects
				obj.update dt
			end for
		end if

		// update rocket display (camera follows player ship)
		worldRenderer.rocketPos = ship.pos
		worldRenderer.update

		// draw orbits for all space objects
		if not ship.crashed then worldRenderer.drawOrbit ship.orbit
		for obj in spaceObjects
			if refEquals(obj, ship) then continue
			if obj.crashed then continue
			if obj.orbit and obj.orbit.isValid then
				worldRenderer.drawOrbit obj.orbit, "#FFAA44"
			end if
		end for

		// draw non-player space objects
		worldRenderer.drawDebris

		cockpitUI.drawShipInfo ship.speed, ship.alt
	end while
	key.clear
end function

if locals == globals then
	setup
	mainLoop
end if
