// This module runs the Rocket Assembly scene, in which users build
// or edit a rocket by dragging parts out from a parts palette, and
// snapping them together.

import "importUtil"
ensureImport "miscUtils"
ensureImport "listUtil"
ensureImport "mathUtil"
ensureImport "stringUtil"
ensureImport "Rect"
ensureImport "sounds"
ensureImport "assemblyPalette"

partImages = []
for i in range(0, 6)
	partImages.push Image.create(128, 128, color.white)
end for

// Component: a single, indivisible ship part.  Each component has one or
// more attachment points by which it can attach to other components in an assembly.
Component = {}
Component.pos = null          // x,y position on screen
Component.attachPoints = null // list of AttachPoint
Component.sprite = null       // Sprite representing this component

Component.boundsRect = function
	w = self.sprite.localBounds.width
	h = self.sprite.localBounds.height
	return Rect.MakeLBWH(self.pos[0] - w/2, self.pos[1] - h/2, w, h)
end function

Component.Make = function(image)
	noob = new self
	noob.pos = [480,320]
	noob.attachPoints = []
	noob.sprite = new Sprite
	noob.sprite.image = image
	noob.sprite.localBounds = new Bounds
	noob.sprite.localBounds.width = image.width
	noob.sprite.localBounds.height = image.height
	return noob
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

Dir = {"E":0, "N":1, "W":2, "S":3}
Size = {"TINY":0, "SMALL":1, "LARGE":2, "HUGE":3}

// AttachPoint: a place on a component that can attach to other components, at
// a compatible AttachPoint.  To be compatible, it must be of the same size and
// opposite orientation.
AttachPoint = {}
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
Assembly = {}
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

Assembly.update = function
	for comp in self.components
		comp.update
	end for
end function


Palette = assemblyPalette.Palette
Palette.makeAssemblyCallback = function(partDef, xy)
	comp = Component.Make(partDef.image)
	comp.pos = xyList(xy)
	comp.pos[0] += 50

	hw = comp.sprite.image.width / 2
	hh = comp.sprite.image.height / 2
	if partDef.anchors.contains("N") then
		comp.attachPoints.push AttachPoint.Make([0, hh],  Dir.N, Size.SMALL)
	end if
	if partDef.anchors.contains("S") then
		comp.attachPoints.push AttachPoint.Make([0, -hh], Dir.S, Size.SMALL)
	end if
	if partDef.anchors.contains("E") then
		comp.attachPoints.push AttachPoint.Make([hw, 0],  Dir.E, Size.SMALL)
	end if
	if partDef.anchors.contains("W") then
		comp.attachPoints.push AttachPoint.Make([-hw, 0], Dir.W, Size.SMALL)
	end if

	comp.addToDisplay spriteDisp

	assm = Assembly.Make
	assm.components.push comp
	assm.update
	assm.updateBounds
	return assm
end function

// Manager: runs the whole rocket-assembly process.
State = {}
State.IDLE = "IDLE"
State.MOUSEDOWN = "MOUSEDOWN"
State.DRAGGING = "DRAGGING"
Manager = {}
Manager.state = ""
Manager.stateStartTime = 0
Manager.assemblies = []
Manager.hitAssem = null  // Assembly currently being clicked or dragged
Manager.hitDelta = [0,0] // hitAssem pos - mouse pos

Manager.assemblyAtXY = function(xy)
	result = null
	for assm in self.assemblies
		if assm.contains(xy) then result = assm
	end for
	return result
end function

Manager.snapAssembly = function(assem, dpos)
	// If we move the given assembly by dpos, will it be close enough
	// to snap to something?  If so, adjust dpos so it fits exactly.
	// Return true if snapped, false otherwise.
	for other in self.assemblies
		if other == assem then continue
		if assem.trySnapTo(other, dpos) then
			assem.snappingTo = other
			return true
		end if
	end for
	assem.snappingTo = null
	return false
end function

Manager.timeInState = function; return time - self.stateStartTime; end function

Manager.enterState = function(newState)
	if newState == self.state then return
	self.exitState newState
	
	if newState == State.MOUSEDOWN then
		self.mouseDownPos = [mouse.x, mouse.y]
		if self.hitAssem then self.hitDelta = self.hitAssem.pos.minus(self.mouseDownPos)
	else if newState == State.DRAGGING then
		if self.hitAssem and (key.pressed("left alt") or key.pressed("right alt")) then
			delta = [mouse.x, mouse.y].minus(self.mouseDownPos)
			if abs(delta[0]) > abs(delta[1]) then delta[1] = 0 else delta[0] = 0
			delta.normalize
			self.hitAssem.breakAt self.mouseDownPos, delta
			self.hitDelta = self.hitAssem.pos.minus(self.mouseDownPos)
		end if
	end if
	
	self.state = newState
	self.stateStartTime = time
end function

Manager.exitState = function(toNewState)
	if self.state == State.DRAGGING then
		if self.hitAssem.snappingTo and self.hitAssem.attach(self.hitAssem.snappingTo) then
			// The hit assembly has been merged into the other one.
			// So now we can forget it.
			self.assemblies.removeVal self.hitAssem
		end if
		self.hitAssem = null
	end if
end function

Manager.updateState = function
	if self.state == State.IDLE then
		if mouse.button then
			if Palette.contains(mouse) then
				self.hitAssem = Palette.makeAssemblyAtXY(mouse)
				if self.hitAssem then self.assemblies.push self.hitAssem
			else
				self.hitAssem = self.assemblyAtXY(mouse)
			end if
			if self.hitAssem then self.enterState State.MOUSEDOWN
		end if
	else if self.state == State.MOUSEDOWN then
		if not mouse.button then
			self.enterState State.IDLE
		else if self.timeInState > 1 then 
			// Automatically start a drag (rather than selection) on long-press
			self.enterState State.DRAGGING
		else if mathUtil.distance(mouse, self.mouseDownPos) > 3 then
			// Also start a drag if the user starts dragging!
			self.enterState State.DRAGGING
		end if
	else if self.state == State.DRAGGING then
		if not mouse.button then
			self.enterState State.IDLE
		else
			pos = self.hitDelta.plus([mouse.x, mouse.y])
			if self.hitAssem.pos != pos then self.hitAssem.moveTo pos
		end if
	end if
end function

main = function
	clear
	gfx.clear "#4A6DE5"
	sounds.init
	globals.spriteDisp = display(4)
	Palette.draw
	
	Manager.enterState State.IDLE
	
	while true
		yield
		if key.available then
			k = key.get
			if k == char(27) then break
		end if
		Manager.updateState
	end while
	text.color = color.orange
end function

if locals == globals then main
