
frames = []

for i in range(0, 9)
	frames.push file.loadImage("/usr/pics/UI/numbers/" + i + ".png")
end for

Number = new Sprite
Number.image = frames[0]
Number.setNumber = function(num)
	if num isa string then
		self.image = frames[val(num)]
	else
		self.image = frames[num]
	end if
end function