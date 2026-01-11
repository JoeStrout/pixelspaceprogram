// Sprite animation system

dsl.anim = {}

_anim = {}
_anim.frames = null
_anim.speed = 10
_anim.frame = 0

// this function assumes that the spriteSheet stores sprites horizontaly
dsl.anim.create = function(spriteSheet, width, speed=10)
	a = new _anim
	a.speed = speed
	a.frames = []

	height = spriteSheet.height
	amount = spriteSheet.width / width

	for i in range(0, amount-1)
		a.frames.push spriteSheet.getImage(width * i, 0, width, height)
	end for

	return a
end function

dsl.anim.animate = function(sprite, animation)
	sprite.image = animation.frames[time * animation.speed % animation.frames.len]
end function