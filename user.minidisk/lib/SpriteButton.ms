// SpriteButton: a button based on a Sprite, with hover/press
// tinting and keyboard shortcut support.
// Similar API to uiWidgets.Button, but sprite-based.

import "importUtil"
ensureImport "helpTag"

SB = new Sprite
SB.normalColor = "#CCCCCC"
SB.hoverColor = "#FFFFFF"
SB.pressedColor = "#888888"
SB.wasPressed = false
SB.wasHovered = false
SB.action = null
SB.shortcutKeys = null
SB.hoverStart = 0
SB.helpShowing = false
SB.Instances = []
SB.helpText = ""


SB.Make = function(img, x=0, y=0, keys=null)
	if img isa string then
		path = img
		img = file.loadImage(path)
		if img == null then
			print "Unable to load image: " + path
			exit
		end if
	end if
	noob = new self
	noob.image = img
	noob.x = x
	noob.y = y
	noob.localBounds = new Bounds
	noob.localBounds.width = img.width
	noob.localBounds.height = img.height
	if keys isa string then keys = [keys]
	if keys then
		noob.shortcutKeys = keys
		parts = []
		for k in keys
			parts.push "[" + k + "]"
		end for
		noob.helpText = parts.join(", ")		
	end if
	self.Instances.push noob
	noob.tint = noob.normalColor
	noob.wasHovered = "<new>"  // forces draw on first update
	return noob
end function

SB.close = function
	SB.Instances.removeVal self
	idx = self.spriteDisplay.sprites.indexOf(self)
	if idx != null then self.spriteDisplay.sprites.remove idx
end function

SB.draw = function(hovered=false, pressed=false)
	if pressed then
		self.tint = self.pressedColor
	else if hovered then
		self.tint = self.hoverColor
	else
		self.tint = self.normalColor
	end if
	self.wasPressed = pressed
	self.wasHovered = hovered
end function

SB.update = function
	hovered = self.contains([mouse.x, mouse.y])
	if hovered != self.wasHovered then
		self.draw hovered
		if hovered then
			self.hoverStart = time
		else
			if self.helpShowing then
				helpTag.clear
				self.helpShowing = false
			end if
		end if
	end if
	if hovered and self.helpText and not self.helpShowing then
		if time - self.hoverStart >= 1 then
			helpTag.show self.helpText, self.x, self.y - self.image.height/2 - 10
			self.helpShowing = true
		end if
	end if
	if hovered and mouse.button then
		// hide help tag during press
		if self.helpShowing then
			helpTag.clear
			self.helpShowing = false
		end if
		// track until mouse-up
		self.draw true, true
		while mouse.button
			yield
			stillOver = self.contains([mouse.x, mouse.y])
			if stillOver != self.wasPressed then self.draw false, stillOver
		end while
		if self.wasPressed then self.action
		self.draw self.contains([mouse.x, mouse.y])
		if self.wasHovered then self.hoverStart = time
	end if
end function

SB.press = function
	self.draw false, true
	wait 0.1
	self.draw
	wait 0.1
	self.action
end function

SB.handleKey = function(keyPressed)
	if not self.shortcutKeys then return false
	for k in self.shortcutKeys
		if k == keyPressed then
			self.press
			return true
		end if
	end for
	return false
end function

SB.UpdateAll = function; for btn in SB.Instances; btn.update; end for; end function

SB.HandleKeyAll = function(keyPressed)
	for btn in SB.Instances; if btn.handleKey(keyPressed) then return true; end for
	return false
end function

demo = function
	ensureImport "displays"
	displays.setup
	disp = displays.hudSprites

	btn = SB.Make(file.loadImage("/usr/pics/UI/launchButton.png"), 480, 400, ["l", char(10)])
	btn.action = function; print "Launch button pressed!"; end function
	btn.helpText = "[L]aunch the rocket"
	disp.sprites.push btn

	btn = SB.Make(file.loadImage("/usr/pics/UI/homeButton.png"), 480, 300, ["h"])
	btn.action = function; print "Home button pressed!"; end function
//	btn.helpText = "Return home"
	disp.sprites.push btn

	exitBtn = SB.Make(file.loadImage("/usr/pics/UI/blankButton.png"), 480, 200, ["q", char(27)])
	exitBtn.action = function; outer.done = true; end function
	exitBtn.helpText = "Quit demo"
	disp.sprites.push exitBtn

	text.row = 26
	print "SpriteButton demo. Click buttons or use keys:"
	print "  L / Enter = Launch"
	print "  H = Home"
	print "  Q / Esc = Exit"

	done = false
	while not done
		SB.UpdateAll
		if key.available then SB.HandleKeyAll key.get
		yield
	end while
	SB.Instances = []
	disp.sprites = []
end function

if locals == globals then demo else return SB
