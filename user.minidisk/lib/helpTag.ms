// helpTag: shows a temporary help tag (tooltip) as a sprite on the HUD.
// Usage:
//   helpTag.show "Some help text", x, y
//   helpTag.clear

import "importUtil"
ensureImport "displays"

sprite = null

show = function(helpText, x, y)
	w = helpText.len * 8 + 4
	h = 16
	disp = new PixelDisplay
	disp.clear "#FFFFAA", w, h
	disp.print helpText, 2, 2, color.black, "small"
	img = disp.getImage(0, 0, w, h)

	if outer.sprite != null then outer.clear
	outer.sprite = new Sprite
	outer.sprite.image = img
	outer.sprite.x = x
	outer.sprite.y = y
	displays.hudSprites.sprites.push outer.sprite
end function

clear = function
	if outer.sprite == null then return
	idx = displays.hudSprites.sprites.indexOf(outer.sprite)
	if idx != null then displays.hudSprites.sprites.remove idx
	outer.sprite = null
end function

demo = function
	displays.setup

	show "Hello, World!", 480, 400
	print "Showing 'Hello, World!' at (480, 400)"
	print "Press any key to change text..."
	key.get

	show "A longer help tag for testing", 300, 300
	print "Now showing longer text at (300, 300)"
	print "Press any key to clear..."
	key.get

	outer.clear
	print "Tag cleared."
end function

if locals == globals then demo
