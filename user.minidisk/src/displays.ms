// This module defines which Mini Micro displays are used for what,
// and configures them appropriately.


setup = function
	clear
	// Setting things up from back to front:

	// Pixel layer, used for the main exterior view (planets/orbits):
	display(6).mode = displayMode.pixel
	outer.exterior = display(6)
	exterior.clear color.black
	globals.gfx = exterior  // (also gfx)

	// Sprite layer, used for derplings, orbit icons, rocket, rover, etc.;
	// also for any HUD elements that need to go *under* the HUD pixels:
	display(5).mode = displayMode.sprite
	outer.outerSprites = display(5)
	outerSprites.clear
	
	// Pixel layer used for cockpit instruments and HUD drawing:
	display(4).mode = displayMode.pixel
	outer.hud = display(4)
	hud.clear color.clear
	
	// Sprite layer for sprite stuff that goes on top of the HUD pixel layer:
	display(3).mode = displayMode.sprite
	outer.hudSprites = display(3)
	hudSprites.clear
	
	// Text -- mostly used in debugging; we probably won't use it when the
	// game is done.
	display(2).mode = displayMode.text
	globals.text = display(2)
	text.color = color.orange
	text.clear
	
	// Displays 1 and 0 reserved for future use.  :)
end function


dump = function
	// Print the status of all displays.
	for i in range(0, 7)
		d = display(i)
		mode = d.mode
		s = displayMode.str(mode)
		if mode == displayMode.solidColor then
			s += " (" + d.color + ")"
		else if mode == displayMode.pixel then
			s += " (" + d.width + " x " + d.height
			s += ", scale=" + d.scale
			s += ", scroll=" + d.scrollX + "," + d.scrollY + ")"
		else if mode == displayMode.sprite then
			s += " (" + d.sprites.len + " sprites)"
		end if
		if refEquals(d, exterior) then s += "  <-- exterior"
		if refEquals(d, gfx) then s += "  <-- gfx"
		if refEquals(d, outerSprites) then s += "  <-- outerSprites"
		if refEquals(d, hud) then s += "  <-- hud"
		if refEquals(d, hudSprites) then s += "  <-- hudSprites"
		if refEquals(d, text) then s += "  <-- text"
		
		print i + ". " + s
	end for
end function


if locals == globals then
	setup
	print "Displays set up."
	dump
end if
