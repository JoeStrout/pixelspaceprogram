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
ensureImport "assembly"
ensureImport "assemblyPalette"
ensureImport "uiWidgets"

Dir = assembly.Dir
Size = assembly.Size

Palette = assemblyPalette.Palette
Palette.makeAssemblyCallback = function(partDef, xy)
	comp = Component.Make(partDef)
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

goHome = function
	text.row = 0
	text.color = color.orange
	print "Home scene not yet implemented."
	exit
end function

goToLaunchPad = function
	run "mainScene"
end function

main = function
	clear
	gfx.clear "#4A6DE5"
	sounds.init
	globals.spriteDisp = display(4)
	Palette.draw
	
	homeBtn = Button.Make("", 920, 600)
	homeBtn.width = 32; homeBtn.height = 32
	homeBtn.image = file.loadImage("/usr/pics/UI/homeButton.png")
	homeBtn.action = @goHome

	launchBtn = Button.Make("", 880, 600)
	launchBtn.width = 32; launchBtn.height = 32
	launchBtn.image = file.loadImage("/usr/pics/UI/launchButton.png")
	launchBtn.action = @goToLaunchPad
	
	Manager.enterState State.IDLE
	
	while true
		yield
		if key.available then Button.HandleKeyAll(key.get)
		Manager.updateState
		Button.UpdateAll
	end while
	text.color = color.orange
end function

if locals == globals then main
