import "importUtil"
ensureImport "DSL"
ensureImport "worldRenderer"
ensureImport "DerpClass"
ensureImport "Rover"

setup = function
	clear

	displays.setup
	worldRenderer.setup
	worldRenderer.refScreenPos = [480,320]
	worldRenderer.zoomToScaleIdx 3

	globals.derp = new Derp
	derp.calculateScale worldRenderer.pixelScale

	//globals.rover = new Rover.rover
	//rover.x = 480; rover.y = 320
	//rover.init


	derp.init 480, 320
	//derp.rover = rover

	display(2).mode = displayMode.pixel
	display(2).clear
	
	globals.timeScale = 0
end function

mainLoop = function
	while true
		yield

		dsl.update

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

		derp.calculateScale worldRenderer.pixelScale
		//rover.calculateScale worldRenderer.pixelScale

		derp.cols = worldRenderer.visiblePoly

		if timeScale > 0 then 
			derp.update timeScale/60, worldRenderer.pixelScale
			//rover.update timeScale/60
		end if

		if derp.inControl then
			//pos = worldRenderer.screenToWorld([derp.x, derp.y])
			//worldRenderer.rocketPos = pos
		end if

		worldRenderer.drawWorld worldRenderer.refScreenPos, [-worldRenderer.rocketPos[0], -worldRenderer.rocketPos[1]]

		//rover.leftWheel.cols = worldRenderer.visiblePoly
		//rover.rightWheel.cols = worldRenderer.visiblePoly


	end while
	key.clear
end function

if locals == globals then
	setup
	mainLoop
	clear
end if
