// Various user interface widgets, like buttons and sliders or whatever.
// These work in a PixelDisplay.

import "importUtil"
ensureImport "stringUtil"
ensureImport "listUtil"
ensureImport "bmfFonts"
ensureImport "gui"
ensureImport "Rect"

Image9Slice = gui.Image9Slice

globals.Button = new Rect
Button.normalColor = "#339933"
Button.hoverColor = "#AAFFAA"
Button.pressedColor = "#44AA44"
Button.textColor = "#99FF99"
Button.image = file.loadImage("/usr/pics/UI/blankButton.png")  // may be Image or Image9Slice
Button.font = bmfFonts.Font.load("/sys/fonts/NotoSansBold-14.bmf")
Button.display = gfx
Button.left = 480
Button.bottom = 320
Button.width = 80
Button.height = 32
Button.caption = "Button"
Button.wasPressed = false
Button.wasHovered = false
Button.action = null
Button.shortcutKeys = null
Button.Instances = []

Button.Make = function(caption="Button", centerX=480, centerY=320, width=80, height=32, keys=null)
	noob = new self
	noob.width = width
	noob.height = height
	noob.setCenter centerX, centerY
	noob.caption = caption
	if keys isa string then keys = [keys]
	if keys then noob.shortcutKeys = keys
	self.Instances.push noob
	self.wasHovered = "<new>"  // (forces draw on first update)
	return noob
end function

Button.close = function
	Button.Instances.removeVal self
	self.display.fillRect self.left, self.bottom,
	  self.width, self.height, color.clear
end function

Button.draw = function(hovered=false, pressed=false)
	if pressed then
		c = self.pressedColor
	else
		if hovered then c = self.hoverColor else c = self.normalColor
	end if
	if self.image isa Image9Slice then
		self.image.draw self.display, self.left, self.bottom,
		  self.width, self.height, c
	else
		self.display.drawImage self.image, self.left, self.bottom,
		  self.width, self.height, 0, 0, -1, -1, c
	end if
	if self.caption then
		f = self.font
		oldGfx = gfx
		globals.gfx = self.display
		f.printCentered self.caption, self.centerX, self.centerY - f.lineHeight/2 + 3, 1, self.textColor
		globals.gfx = oldGfx
	end if
	self.wasPressed = pressed
	self.wasHovered = hovered
end function

Button.update = function
	hovered = self.contains(mouse)
	if hovered != self.wasHovered then self.draw hovered
	if hovered and mouse.button then
		// track until mouse-up!
		self.draw true, true
		while mouse.button
			yield
			stillOver = self.contains(mouse)
			if stillOver != self.wasPressed then self.draw false, stillOver
		end while
		if self.wasPressed then self.action
		self.draw self.contains(mouse)
	end if
end function

Button.press = function
	self.draw false, true
	wait 0.1
	self.draw
	wait 0.1
	self.action
end function

Button.handleKey = function(keyPressed)
	if not self.shortcutKeys then return false
	for k in self.shortcutKeys
		if k == keyPressed then
			self.press
			return true
		end if
	end for
	return false
end function

Button.UpdateAll = function; for btn in Button.Instances; btn.update; end for; end function

Button.HandleKeyAll = function(keyPressed)
	for btn in Button.Instances; if btn.handleKey(keyPressed) then return true; end for
	return false
end function

demo = function
	clear
	btn = Button.Make("Demo", 480, 500, 80, 32, ["d", char(10)])
	btn.action = function; print "Demo button pressed!"; end function
	
	btn = Button.Make("Exit", 480, 150, 80, 32, ["e", "q", char(27)])
	btn.action = function; outer.done = true; end function
	
	done = false
	while not done
		Button.UpdateAll
		if key.available then Button.HandleKeyAll(key.get)
		yield
	end while
end function

if locals == globals then demo
