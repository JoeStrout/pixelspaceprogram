// This is a helper module for assemblyScene.
// It's responsible for drawing and managing the parts palette
// on the left side of the screen.

// For now this is simple, with just a handful of hard-coded parts.
// We'll add categories and scrolling and tech-tree-savviness later.

import "importUtil"
ensureImport "Rect"
ensureImport "gameData"

Well = new Rect
Well.index = 0   // index within the palette
Well.partDef = null  // PartDef this well represents
Well.size = 80
Well.Make = function(x, y, index, partKey)
	w = new self
	w.setLBWH x, y, self.size, self.size
	w.index = index
	w.partDef = gameData.parts[partKey]
	return w
end function

Palette = {}
Palette.width = 100
Palette.wells = []  // list of Well

Palette.init = function
	parts = ["ruckus", "probeCore", "reactionWheelS", "decouplerS", "sideDecoupler"]
	iconSize = 64
	gap = 20
	x = (self.width - Well.size)/2
	y = 640 - gap
	for i in parts.indexes
		y -= Well.size
		r = Rect.MakeLBWH(x, y, Well.size, Well.size)
		self.wells.push Well.Make(x, y, i, parts[i])
		y -= gap
	end for
end function
		
Palette.draw = function
	if not self.wells then self.init
	gfx.fillRect 0, 0, self.width, 640, "#666666"
	for well in self.wells
		well.draw "#444444"
		img = well.partDef.image
		scale = min(64/img.height, 64/img.width)
		h = img.height * scale
		w = img.width * scale
		gfx.drawImage img,
		   well.centerX - w/2, well.centerY - h/2, w, h,
		   0, 0, -1, -1, "#CCCCCC"
	end for
end function

Palette.contains = function(xy)
	if xy isa map then return xy.x < self.width
	return xy[0] < self.width
end function

Palette.wellAt = function(xy)
	for w in self.wells
		if w.contains(xy) then return w
	end for
	return null
end function

Palette.makeAssemblyAtXY = function(xy)
	well = self.wellAt(xy)
	if not well then return null
	return self.makeAssemblyCallback(well.partDef, xy)
end function

Palette.makeAssemblyCallback = function(partDef, xy)
	// Assembly scene should replace this with code 
	// to make and return a new Assembly.
end function

if locals == globals then
	print "This module does nothing on its own."
	print "Run assemblyScene instead."
end if
