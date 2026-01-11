// Game loop
globals.dsl = {}

// Library features
import "DSL_Debug"
import "DSL_Input"
import "DSL_Animations"
import "DSL_Log"

dsl.running = true

dsl.frameCount = 0
dsl.lastTime = 0
dsl.dt = 1/60

dsl.fpsTimer = 0
dsl.fpsFrames = 0
dsl.fpsValue = 0

dsl.stop = function; dsl.running = false; end function
dsl.loop = function; end function
dsl.fps = function; return dsl.fpsValue; end function

dsl.update = function
	// Delta time calculation
	dsl.frameCount += 1
	dsl.dt = time - dsl.lastTime
	dsl.lastTime = time

	// FPS calculation
	dsl.fpsTimer += dsl.dt
	dsl.fpsFrames += 1

	if dsl.fpsTimer >= 1 then
		dsl.fpsValue = dsl.fpsFrames / dsl.fpsTimer
		dsl.fpsTimer = 0
		dsl.fpsFrames = 0
	end if
end function

dsl._scanFolder = function(path, ext)
	filesFound = []

	for f in file.children(path)
		fileOrFolder = path + "/" + f

		if not file.info(fileOrFolder).isDirectory then
			fileName = file.name(fileOrFolder)

			if fileName.indexOf(".") == null then continue

			fN = fileName.split(".")

			fN[0] = fN[0].replace(" ", "_")
			fN[0] = fN[0].replace("-", "_")

			if fN[1] == ext then
				filesFound.push {"name": fN[0], "path": fileOrFolder}
			end if
		else
			imgs = dsl._scanFolder(fileOrFolder, ext)

			for ff in imgs
				filesFound.push ff
			end for
		end if
	end for

	return filesFound
end function

dsl.images = {}
dsl.importImages = function(folder="")
	if folder == "" then
		path = pwd
	else
		path = pwd + "/" + folder
	end if

	filesFound = dsl._scanFolder(path, "png")

	for f in filesFound
		dsl.images[f.name] = file.loadImage(f.path)
	end for
end function

dsl.sounds = {}
dsl.importSounds = function(folder)
	if folder == "" then
		path = pwd
	else
		path = pwd + "/" + folder
	end if

	filesFound = dsl._scanFolder(path, "wav")

	for f in filesFound
		dsl.sounds[f.name] = file.loadSound(f.path)
	end for
end function