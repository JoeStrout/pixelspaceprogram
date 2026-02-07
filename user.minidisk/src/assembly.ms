// This module defines the Component, AttachPoint, and Assembly classes,
// which together define how a ship is composed of parts.

import "importUtil"
ensureImport "miscUtils"
ensureImport "gameData"
ensureImport "Rect"

// Constants
Dir = {"E":0, "N":1, "W":2, "S":3}
Size = {"TINY":0, "SMALL":1, "LARGE":2, "HUGE":3}

// Component: a single, indivisible ship part.  Each component has one or
// more attachment points by which it can attach to other components in an assembly.
globals.Component = {}
Component.partDef = null      // PartDef of game data for this part
Component.pos = null          // x,y position on screen
Component.attachPoints = null // list of AttachPoint
Component.sprite = null       // Sprite representing this component

Component.boundsRect = function
	w = self.sprite.localBounds.width
	h = self.sprite.localBounds.height
	return Rect.MakeLBWH(self.pos[0] - w/2, self.pos[1] - h/2, w, h)
end function

Component.Make = function(partDef)
	noob = new self
	noob.partDef = partDef
	noob.pos = [480,320]
	noob.attachPoints = []
	noob.sprite = new Sprite
	noob.sprite.image = partDef.image
	noob.sprite.localBounds = new Bounds
	noob.sprite.localBounds.width = partDef.image.width
	noob.sprite.localBounds.height = partDef.image.height
	if partDef isa EngineDef then
		noob.fuelMass = partDef.fuelMass
		noob.mass = function; return self.partDef.dryMass + self.fuelMass; end function
	end if
	return noob
end function

Component.mass = function
	return self.partDef.mass
end function

// Fuel left, from 0 - 100 %  (call this only on engine or fuel tank parts!)
Component.fuelPct = function
	return self.fuelMass / self.partDef.fuelMass * 100
end function


Component.update = function
	x = self.pos[0]; y = self.pos[1]
	self.sprite.x = x; self.sprite.y = y
	for pt in self.attachPoints
		pt.sprite.x = x + pt.localPos[0]
		pt.sprite.y = y + pt.localPos[1]
	end for
end function

Component.addToDisplay = function(disp)
	disp.sprites.push self.sprite
	for pt in self.attachPoints
		disp.sprites.push pt.sprite
	end for
end function

Component.contains = function(xy)
	return self.sprite.contains(xy)
end function

Component.breakAttachment = function(toOther)
	for atch in self.attachPoints
		if atch.attached == toOther then atch.attached = null
	end for
	// Note: it's up to the caller to do the reverse call, too.
end function

// AttachPoint: a place on a component that can attach to other components, at
// a compatible AttachPoint.  To be compatible, it must be of the same size and
// opposite orientation.
globals.AttachPoint = {}
AttachPoint.localPos = null  // [x, y] relative to owning component
AttachPoint.orientation = 0  // 0=East, 1=North, 2=West, 3=South
AttachPoint.size = 1         // 0=tiny, 1=small, 2=large, 3=huge
AttachPoint.attached = null  // other Component attached at this point
AttachPoint.sprite = null    // Sprite representing this point

picsFolder = "/usr/pics"
AttachPoint.srcImages = [
	file.loadImage(picsFolder + "/attachPointA.png"),
	file.loadImage(picsFolder + "/attachPointB.png") ]

AttachPoint.Make = function(localPos, orientation=0, size=1)
	noob = new self
	noob.localPos = localPos
	noob.orientation = orientation
	noob.size = size
	noob.sprite = new Sprite
	noob.sprite.image = self.srcImages[orientation > 1]
	// ToDo: replace scaling with separate, pixel-perfect images for each size
	noob.sprite.scale = [0.25, 0.5, 0.75, 1][size]
	noob.sprite.rotation = 90 * orientation
	noob.sprite.tint = "#AAAAFF"
	return noob
end function

AttachPoint.compatibleWith = function(other)
	return other.size == self.size and 
	   (other.orientation + 2) % 4 == self.orientation
end function

// Assembly: a collection of one or more components.
globals.Assembly = {}
Assembly.components = null   // list of Components in this assembly
Assembly.boundsRect = null   // total Rect containing all components
Assembly.snappingTo = null   // assembly we're snapping to while dragging

Assembly.Make = function
	noob = new self
	noob.components = []
	return noob
end function

Assembly.pos = function; return self.components[0].pos; end function

Assembly.updateBounds = function
	self.boundsRect = self.components[0].boundsRect
	for i in range(1, self.components.len-1, 1)
		self.boundsRect = self.boundsRect.union(self.components[i].boundsRect)
	end for
end function

Assembly.componentAt = function(xy)
	for comp in self.components
		if comp.contains(xy) then return comp
	end for
	return null
end function

Assembly.contains = function(xy)
	return self.componentAt(xy) != null
end function

Assembly.moveTo = function(xy, allowSnap=true)
	dpos = xy.minus(self.pos)
	// Limit movement to keep the assembly mostly in view
	b = self.boundsRect
	if b.centerX + dpos[0] < 0 then
		dpos[0] = -b.centerX
	else if b.centerX + dpos[0] > 960 then
		dpos[0] = 960 - b.centerX
	end if
	
	// Then, see if we can snap to anything with this dpos
	wasSnapped = (self.snappingTo != null)
	isSnapped = Manager.snapAssembly(self, dpos)
	if isSnapped and not wasSnapped then
		if not sounds.snap.isPlaying then sounds.snap.play
	else if wasSnapped and not isSnapped then
		if not sounds.pop.isPlaying then sounds.pop.play
	end if
	
	// Then update all components, and our own boundsRect
	for comp in self.components
		comp.pos.add dpos
		comp.update
	end for
	self.updateBounds
end function

Assembly.ownerOf = function(attachPoint)
	// Return the Component in our assembly that owns the given AttachPoint.
	for comp in self.components
		if comp.attachPoints.contains(attachPoint) then return comp
	end for
	return null
end function

Assembly.allOpenAttachPoints = function
	// Return a list of all the open attachment points on this assembly,
	// with current worldPos filled in.
	result = []
	for comp in self.components
		for pt in comp.attachPoints
			if pt.attached then continue
			pt.worldPos = comp.pos.plus(pt.localPos)
			result.push pt
		end for
	end for
	return result
end function

Assembly.trySnapTo = function(other, dpos)
	// If this assembly is moved by dpos, can it snap to the given
	// other assembly?  If so, adjust dpos so it fits exactly and
	// return true.  Otherwise, return false.
	myPts = self.allOpenAttachPoints
	otherPts = other.allOpenAttachPoints
	for myPt in myPts
		myPt.worldPos.add dpos  // adjust for the new position!
		for otherPt in otherPts
			if not myPt.compatibleWith(otherPt) then continue
			dist = mathUtil.distance(myPt.worldPos, otherPt.worldPos)
			if dist > 10 then continue
			// Found an attachment that works!
			dpos.add otherPt.worldPos.minus(myPt.worldPos)
			return true
		end for
	end for
	return false
end function

Assembly.attach = function(other)
	// Find all overlapping compatible attachment points between
	// this assembly and the other one, and hook them up.  Then
	// incorporate our components into the other assembly.  This
	// assembly is then ready to be deleted.  Return true if
	// successful, false if no attachment was done.
	success = false
	myPts = self.allOpenAttachPoints
	otherPts = other.allOpenAttachPoints
	for myPt in myPts
		for otherPt in otherPts
			if not myPt.compatibleWith(otherPt) then continue
			dist = mathUtil.distance(myPt.worldPos, otherPt.worldPos)
			if dist > 1 then continue
			// Found an attachment that works -- hook it up!
			myPt.attached = other.ownerOf(otherPt)
			otherPt.attached = self.ownerOf(myPt)
			success = true
			break
		end for
	end for
	if not success then return false
	
	// Attachment points connected; now combine components.
	other.components = other.components + self.components
	self.components = []
	return true
end function

Assembly.breakAt = function(breakPos, direction)
	// Find the component at breakPos, and break it (and possibly others
	// attached to it) from the rest of the assembly at breakPos, in the 
	// given ([x,y] normalized, orthogonal) direction.
	breaker = self.componentAt(breakPos)
	if not breaker then return
	// Make a list of all components going with the breaker.
	globals.breaking = [breaker]
	toDo = [breaker]
	while toDo
		comp = toDo.pull
		for atch in comp.attachPoints
			otherComp = atch.attached
			if not otherComp or breaking.contains(otherComp) then continue
			pos = atch.localPos.plus(comp.pos)
			if direction[0] > 0 then shouldBreak = pos[0] > breakPos[0]
			if direction[0] < 0 then shouldBreak = pos[0] < breakPos[0]
			if direction[1] > 0 then shouldBreak = pos[1] > breakPos[1]
			if direction[1] < 0 then shouldBreak = pos[1] < breakPos[1]
			if shouldBreak then
				// Keep this attachment point intact, and recurse on the other component
				breaking.push otherComp
				toDo.push otherComp
			else
				// Break this attachment point.
				comp.breakAttachment otherComp
				otherComp.breakAttachment comp
			end if
		end for
	end while
	// Now, keep the breakers here, and move all other components
	// to a new Assembly.
	noob = Assembly.Make
	for i in range(self.components.len-1, 0, -1)
		comp = self.components[i]
		if not breaking.contains(comp) then
			noob.components.push comp
			self.components.remove i
		end if
	end for
	if not noob.components then return // Nothing to actually break
	sounds.pop.play
	noob.update
	noob.updateBounds
	Manager.assemblies.push noob
	self.update
	self.updateBounds
	self.snappingTo = null
end function

Assembly.renderAt = function(g, x, y)
	for comp in self.components
		img = comp.sprite.image
		g.drawImage img,
		  x + comp.pos[0] - img.width/2,
		  y + comp.pos[1] - img.height/2
	end for
end function

Assembly.boundsRect = function
	if not self.components then return Rect.MakeLBRT(0,0,0,0)
	r = self.components[0].boundsRect
	for i in range(1, self.components.len-1, 1)
		r = r.union(self.components[i].boundsRect)
	end for
	return r
end function

Assembly.recenter = function
	// Shift all component positions so their mass-weighted center
	// of gravity is at [0,0]. Returns the old COG offset (the amount
	// that was subtracted from each component position).
	totalMass = 0
	cogX = 0; cogY = 0
	for comp in self.components
		m = comp.mass
		totalMass += m
		cogX += comp.pos[0] * m
		cogY += comp.pos[1] * m
	end for
	if totalMass == 0 then
		// Fall back to geometric center
		for comp in self.components
			cogX += comp.pos[0]
			cogY += comp.pos[1]
		end for
		cogX = cogX / self.components.len
		cogY = cogY / self.components.len
	else
		cogX = cogX / totalMass
		cogY = cogY / totalMass
	end if
	for comp in self.components
		comp.pos[0] -= cogX
		comp.pos[1] -= cogY
	end for
	return [cogX, cogY]
end function

Assembly.getImage = function
	// Return an image of this Assembly.  Note that this will be 
	// oriented in the standard nose-up orientation; but if you
	// are going to make a rotatable sprite out of it, you probably
	// want to rotate this image -90° first.
	r = self.boundsRect
	g = tempG(r.width, r.height)
	self.renderAt g, -r.left, -r.bottom
	// ToDo: this returns and image centered on its bounds rect,
	// but what we probably want is to always center on the COM.
	// Or maybe not, since that will change as we expend fuel.
	// Figure that out, and revise this method or remove this comment.
	return g.getImage
end function

Assembly.split = function(decouplerComp)
	// Remove the decoupler from our components
	idx = self.components.indexOf(decouplerComp)
	qa.assert idx != null, "Could not find decouplerComp in Assembly.split"
	if idx == null then return null
	self.components.remove idx

	// Break all attachments that reference the decoupler (on both sides)
	for comp in self.components
		comp.breakAttachment decouplerComp
	end for

	// Flood-fill from components[0] to find all connected components
	if not self.components then return null
	connected = [self.components[0]]
	toDo = [self.components[0]]
	while toDo
		comp = toDo.pull
		for atch in comp.attachPoints
			otherComp = atch.attached
			if not otherComp then continue
			if connected.contains(otherComp) then continue
			connected.push otherComp
			toDo.push otherComp
		end for
	end while

	// If everything is still connected, nothing to split
	if connected.len == self.components.len then return null

	// Components NOT in connected set go to a new Assembly
	noob = Assembly.Make
	for i in range(self.components.len - 1, 0, -1)
		comp = self.components[i]
		if connected.indexOf(comp) == null then
			noob.components.push comp
			self.components.remove i
		end if
	end for

	if not noob.components then return null
	return noob
end function

Assembly.update = function
	for comp in self.components
		comp.update
	end for
end function

stack = function(parts)
	// Build and return a new Assembly that has the given list of
	// parts stacked vertically, where parts[0] is bottommost.
	// The parts should be positioned so that they neatly touch,
	// and are attached via their N and S attachment points.
	// Finally, these should be inserted into the new assembly
	// components list in reverse order, so asm.componenst[0] is
	// the top (usually the capsule).
	asm = Assembly.Make

	// First pass: create components and stack them bottom-to-top
	y = 0  // bottom edge of next part
	for partDef in parts
		comp = Component.Make(partDef)
		h = partDef.image.height
		comp.pos = [0, y + h/2]
		asm.components.insert 0, comp
		y += h
	end for

	// Second pass: create attachment points and connect adjacent parts
	for i in range(0, asm.components.len - 2)
		lower = asm.components[i]
		upper = asm.components[i + 1]
		lowerH = lower.partDef.image.height
		upperH = upper.partDef.image.height
		// N point on top of the lower part
		nPt = AttachPoint.Make([0, lowerH/2], Dir.N)
		nPt.attached = upper
		lower.attachPoints.push nPt
		// S point on bottom of the upper part
		sPt = AttachPoint.Make([0, -upperH/2], Dir.S)
		sPt.attached = lower
		upper.attachPoints.push sPt
	end for

	// Third pass: shift all positions so 0,0 is at center of gravity
	totalMass = 0
	cogY = 0
	for comp in asm.components
		m = comp.mass
		totalMass += m
		cogY += comp.pos[1] * m
	end for
	if totalMass > 0 then cogY = cogY / totalMass
	for comp in asm.components
		comp.pos[1] -= cogY
	end for

	return asm
end function

standardTestRocket = function
	// Build and return the our standard test rocket assembly.

	// ToDo: replace the following code...
	asm = Assembly.Make
	
	part = Component.Make(gameData.parts.ruckus)
	part.pos = [0, -61+100]
	asm.components.push part
	
	part = Component.Make(gameData.parts.decouplerS)
	part.pos = [0, -61+100]
	asm.components.push part
	
	part = Component.Make(gameData.parts.probeCore)
	part.pos = [0, 100+100]
	asm.components.push part

	// ...with just this:
	asm = stack([
		gameData.parts.ruckus,
		gameData.parts.decouplerS,
		gameData.parts.ruckus,
		gameData.parts.probeCore])
		
	return asm
end function

if locals == globals then
	clear
	print "Testing assembly.ms"
	
	asm = standardTestRocket
	r = asm.boundsRect
	x = -r.left
	y = -r.bottom
	asm.renderAt gfx, x, y
	r.offset x, y
	r.drawLines "#FF00FF"
	
end if
