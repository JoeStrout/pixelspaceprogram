// This module loads sounds and makes them available to the rest of the game.


allSounds = {}

// playFreqSweep: do a quick sweep between two frequencies.
// Used, for example, to indicate time scale up/down.
playFreqSweep = function(startFreq, endFreq, duration=0.1)
	snd = new Sound
	freq = [startFreq, endFreq]
	envelope = [1, 0.8, 0.8, 0.8, 0]
	snd.init 0.1, freq, envelope, Sound.squareWave
	snd.play
end function


_initialized = false
init = function
	if _initialized then return
	outer._initialized = true
	
	// Load all sounds in the /usr/sounds directory
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
	
	// Add procedural (synthesized) sounds.
	// (Use /sys/demo/soundLab to design these!)
	
	outer.pauseSound = new Sound
	pauseSound.init 0.2, 65.406, [1, 1, 0, 1, 1, 0], Sound.squareWave
	pauseSound.fadeIn = 0.01
	pauseSound.fadeOut = 0.01
	allSounds.push pauseSound
	
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
