import "importUtil"
ensureImport "assembly"
ensureImport "spacecraft"
ensureImport "gameData"
ensureImport "worldRenderer"
ensureImport "Derp"

setup = function
	clear
	
	globals.derp = new Derp.derp
	derp.pos = [0, worldRenderer.worldRadiusAtAngle(pi/2)+25]
	derp.vel = [0, 0]

	worldRenderer.setup
	worldRenderer.refScreenPos = [480,320]
	worldRenderer.zoomToScaleIdx 3

	display(2).mode = displayMode.pixel
	display(2).clear
	
	globals.timeScale = 0
end function

mainLoop = function
	while true
		yield
		// check inputs
		if key.available then
			k = key.get
			if (k == "." or k == ">") and timeScale < 256 then
				if timeScale > 0 then globals.timeScale *= 2 else globals.timeScale = 1
				print "timeScale: " + timeScale
			else if k == "," or k == "<" then
				if timeScale > 1 then globals.timeScale /= 2 else globals.timeScale = 0
			else if k == "+" or k == "=" then
				worldRenderer.zoomIn
			else if k == "-" or k == "_" then
				worldRenderer.zoomOut
			end if
		end if
		
		if key.pressed("escape") then break
		
		// update simulation
		if timeScale > 0 then derp.update timeScale/60
		
		worldRenderer.update
	end while
	key.clear
end function

if locals == globals then
	setup
	mainLoop
end if
