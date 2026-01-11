// This module loads sounds and makes them available to the rest of the game.


allSounds = {}


_initialized = false
init = function
	if _initialized then return
	outer._initialized = true
	dir = "/usr/sounds"
	for fname in file.children(dir)
		if fname[-4:] == ".wav" or fname[-4:] == ".ogg" then
			// load sound
			snd = file.loadSound(file.child(dir, fname))
			// store in allSounds map
			nameWithoutExtension = fname[:-4]
			allSounds[nameWithoutExtension] = snd
			// also stuff into the outer context, so users can just
			// say `sounds.whatever.play`
			outer[nameWithoutExtension] = snd
		end if
	end for
end function

if locals == globals then
	init
	names = allSounds.indexes
	names.sort
	while true
		clear
		for i in names.indexes
			print i + ". " + names[i]
		end for
		print
		numStr = input("Enter number of sound to play: ")
		if numStr == "" or numStr.lower == "q" then break
		allSounds[names[numStr.val]].play
	end while
end if
