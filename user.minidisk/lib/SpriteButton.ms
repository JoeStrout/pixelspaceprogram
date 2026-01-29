SB = new Sprite
SB.init = function(x, y)
	self.x = x
	self.y = y
end function

SB.action = function; end function

SB.checkClick = function
	if dsl.keyPressed("mouse 0") and self.contains([mouse.x, mouse.y]) then
		self.action
	end if
end function