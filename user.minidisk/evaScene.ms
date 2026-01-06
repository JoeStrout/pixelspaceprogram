import "importUtil"
ensureImport "worldRenderer"
ensureImport "Input"
ensureImport "DerpClass"

setup = function
	clear

	worldRenderer.setup
	worldRenderer.refScreenPos = [480,320]
	worldRenderer.zoomToScaleIdx 3

	globals.derp = new Derp
	derp.init 400, 200//0, worldRenderer.worldRadiusAtAngle(pi/2)+156

	derp.xscale = 20
	derp.targetScale = 20


	display(2).mode = displayMode.pixel
	display(2).clear
	
	globals.timeScale = 0
end function

mainLoop = function
	// My input system needs acces to the current frame to 
	// correctly check pressed keys without the need for a loop
	globals.frameCount = 0
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
		
		//worldRenderer.update
		// update simulation
		if timeScale > 0 then derp.update timeScale/60
		
		if Input.keyPressed("mouse 0") then
			mPos = worldRenderer.screenToWorld([mouse.x, mouse.y])
			derp.x = mPos[0]
			derp.y = mPos[1]
			print "Position set"
		end if

		worldRenderer.drawWorld [derp.x, derp.y], [-0, -(worldRenderer.worldRadiusAtAngle(pi/2)+25)]

		globals.frameCount += 1
	end while
	key.clear
end function

if locals == globals then
	setup
	mainLoop
end if
