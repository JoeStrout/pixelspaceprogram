
frames = []

for i in range(0, 9)
	frames.push file.loadImage("/usr/pics/UI/timescale/" + i + ".png")
end for

TSN = new Sprite
TSN.image = frames[0]
TSN.setNumber = function(num)
	if num isa string then
		self.image = frames[val(num)]
	else
		self.image = frames[num]
	end if
end function