
_KeyBoardKeys = {}
_MouseButtons = [{"prev": "up", "state": "up"}] * 3

for kn in key.keyNames
	_KeyBoardKeys[kn] = {"key": kn, "prev": "up", "state": "up"}
end for

globals.updateInput = function
end function

_checkMouseInput = function(mb)
	mouseB = _MouseButtons[mb]
	// mouseB.prevState
end function

_checkKeyInput = function(K)
	_KeyBoardKeys[K].prev = _KeyBoardKeys[K].state
	
	if key.pressed(K) then
		if _KeyBoardKeys[K].state == "released" or _KeyBoardKeys[K].state == "up" then
			_KeyBoardKeys[K].state = "pressed"
		else if _KeyBoardKeys[K].state == "pressed" then
			_KeyBoardKeys[K].state = "down"
		end if
	else
		if _KeyBoardKeys[K].state == "down" or _KeyBoardKeys[K].state == "pressed" then
			_KeyBoardKeys[K].state = "released"
		else if _KeyBoardKeys[K].state == "released" then
			_KeyBoardKeys[K].state = "up"
		end if
	end if
end function

globals.keyPressed = function(k)
	_checkKeyInput k
	return _KeyBoardKeys[k].state == "pressed"
end function

globals.keyDown = function(k)
	_checkKeyInput k
	return _KeyBoardKeys[k].state == "down"
end function

globals.keyReleased = function(k)
	_checkKeyInput k
	
	prev = _KeyBoardKeys[k].prev != "released" and _KeyBoardKeys[k].prev != "up"
	curr = _KeyBoardKeys[k].state == "released"
	
	return prev and curr
end function

globals.keyUp = function(k)
	_checkKeyInput k
	return _KeyBoardKeys[k].state == "up"
end function
