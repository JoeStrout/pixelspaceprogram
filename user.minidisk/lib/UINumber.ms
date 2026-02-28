
frames = []

for i in range(0, 9)
	frames.push file.loadImage("/usr/pics/UI/numbers/" + i + ".png")
end for

Number = new Sprite
Number.image = frames[0]

Number.setNumber = function(num)
	if num isa string then num = val(num)
	if num > 9 then num = 9
	self.image = frames[num]
end function


Number.Make = function(x, y)
	noob = new Number
	noob.x = x
	noob.y = y
	displays.hudSprites.sprites.push noob
	return noob
end function
