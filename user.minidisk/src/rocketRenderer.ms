// This module is responsible for rendering the rocket, with any closely
// related visual effects, like exhaust flames or whatever.

rocketSprite = null
exhaustSprites = []
flameFrames = []
smokeFrames = []
smokeSprites = []

// [x,y] position, in meters, of each flame relative to ship center;
// keep in mind that this is for angle=0 (i.e. ship facing to the right):
exhaustPos = []		


// Setup: call this after globals.ship has been configured with the current ship,
// and our displays are all ready to go.  This method creates the sprites we will
// need, and pushes them into the appropriate display.
setup = function
	outer.rocketIcon = file.loadImage("/usr/pics/rocketIcon.png")

	outer.smokeFrames.push file.loadImage("/usr/pics/smokePuff.png")
	
	outer.flameFrames = []
	p = file.loadImage("/usr/pics/engineFlames.png")
	h = p.height/4
	for i in range(0,3)
		flameFrames.push p.getImage(0, i*h, p.width, h)
	end for
	
	// For now, we'll hard-code a single exhaust sprite.
	// ToDo: get this from the ship design.
	es = new Sprite
	es.image = flameFrames[0]
	es.scale = 0  // (until needed)
	displays.outerSprites.sprites.push es
	exhaustSprites.push es
	exhaustPos.push [-16, 0]
	
	outer.rocketSprite = new Sprite
	rocketSprite.image = null
	rocketSprite.imageScale = 0.1 // m/pixel at which the actual image is created
	rocketSprite.rotation = 90

	displays.outerSprites.sprites.push rocketSprite
	
	outer.boomSound = file.loadSound("/sys/sounds/airburst.wav")

end function

shipLocalToScreen = function(localPos, shipScreenPos, pixelScale)
	ang = ship.angle
	cosAng = cos(ang)
	sinAng = sin(ang)
	x = localPos[0] / pixelScale
	y = localPos[1] / pixelScale
	return [
		shipScreenPos[0] + x * cosAng - y * sinAng,
		shipScreenPos[1] + x * sinAng + y * cosAng ]
end function

SmokeSprite = new Sprite
SmokeSprite.startTime = 0
SmokeSprite.v = [0,1]  // (pixels/sec)
SmokeSprite.update = function(shipPos, pixelScale, time)
	age = time - self.startTime
	d = age / pixelScale
	self.x = shipPos[0] + self.v[0] * d
	self.y = shipPos[1] + self.v[1] * d
	self.scale = 0.5 / pixelScale
	alpha = cos(age / 2)
	if alpha <= 0 then
		self.tint = color.clear
		return false // dead
	else
		self.tint = color.rgba(255,255,255,255*alpha)
		return true	// still alive
	end if
end function
SmokeSprite.Make = function(now)
	ss = new SmokeSprite
	ss.startTime = now
	ss.image = smokeFrames.any
	ss.v = [15*(rnd-0.5), 15*(rnd-0.25)]
	displays.outerSprites.sprites.push ss
	smokeSprites.push ss
	return ss
end function

updateExplosion = function(screenPos, pixelScale)
	if not smokeSprites then
		displays.outerSprites.sprites.removeVal rocketSprite
		for es in exhaustSprites
			displays.outerSprites.sprites.removeVal es
		end for
		boomSound.play
	end if
	now = time
	extraTime = 0
	while smokeSprites.len < 10
		SmokeSprite.Make now + extraTime
		extraTime += 0.25
	end while
	
	for i in range(smokeSprites.len-1, 0, -1)
		if not smokeSprites[i].update(screenPos, pixelScale, now) then
			smokeSprites.remove i
		end if		
	end for
	
end function

// update: draw our rocket, at the given screen position
// and pixel scale.  If we're zoomed too far out, switch
// to a constant-size icon.
update = function(screenPos, pixelScale)
	if ship.crashed then
		updateExplosion screenPos, pixelScale
		return
	end if
	
	rocketSprite.x = screenPos[0]
	rocketSprite.y = screenPos[1]
	degrees = ship.angle * 180/pi
	rocketSprite.rotation = degrees
	
	imgScale = rocketSprite.imageScale / pixelScale
	if pixelScale <= 1 then
		rocketSprite.scale = imgScale
		rocketSprite.image = ship.image
		for i in exhaustSprites.indexes
			es = exhaustSprites[i]
			if ship.thrusting then
				es.scale = imgScale * ship.throttle
				p = shipLocalToScreen(exhaustPos[i], screenPos, pixelScale)
				es.x = p[0]
				es.y = p[1]
				es.scale = imgScale
				es.rotation = degrees
				es.image = flameFrames.any
			else
				es.scale = 0
			end if
		end for
	else
		rocketSprite.scale = 1
		rocketSprite.image = rocketIcon
		for es in exhaustSprites
			es.scale = 0
		end for
	end if
end function
