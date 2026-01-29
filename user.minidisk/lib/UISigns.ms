
frames = {}

for i in ["m", "km", "Mkm", "ms", "kms", "Mkms"]
	frames[i] = file.loadImage("/usr/pics/UI/altitude/" + i + ".png")
end for

Sign = new Sprite
Sign.setSign = function(sign)
	self.image = frames[sign]
end function