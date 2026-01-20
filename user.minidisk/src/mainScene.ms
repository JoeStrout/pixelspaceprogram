// This is the main game scene, presenting an external view of the spacecraft
// and/or explorer character.  This is where you fly (and may also be where
// you walk around, though we should probably separate as much of the EVA code
// into a separate module as we can).

import "importUtil"
ensureImport "assembly"
ensureImport "spacecraft"
ensureImport "gameData"
ensureImport "worldRenderer"
ensureImport "cockpitUI"

setup = function
	displays.setup
	cockpitUI.init
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
	worldRenderer.refScreenPos = [480,320]
	worldRenderer.zoomToScaleIdx 3
	
	cockpitUI.draw

	displays.hud.print "Thrust:         shift", 10, 70, color.silver, "small"
	displays.hud.print "Rotate ship:    ← →", 10, 55, color.silver, "small"
	displays.hud.print "Zoom in/out:    + -", 10, 40, color.silver, "small"
	displays.hud.print "Time fast/slow: . ,", 10, 25, color.silver, "small"
	
	globals.timeScale = 1
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
		
		if key.pressed("p") then
			text.print displays.hudSprites.sprites
		end if

		if key.pressed("escape") then break
		
		// update simulation
		if timeScale > 0 then ship.update timeScale/60
		
		// update rocket display
		worldRenderer.rocketSprite.rotation = ship.angle * 180/pi	
		worldRenderer.rocketPos = ship.pos
		worldRenderer.update
		worldRenderer.drawOrbit ship.orbit
		//spacecraft.drawInfo ship, timeScale

		cockpitUI.drawShipInfo ship.speed, ship.alt 
	end while
	key.clear
end function

if locals == globals then
	setup
	mainLoop
end if
