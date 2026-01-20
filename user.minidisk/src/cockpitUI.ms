// This module implements the "cockpit" or main flight UI:
// the big instrument panel on the right, plus the stage panels.

import "importUtil"
ensureImport "spacecraft"
ensureImport "qa"
ensureImport "displays"
ensureImport "UINumber"
ensureImport "UISigns"

pic = {}

altSprites = []
uiSigns = []

init = function
	if pic.len then return // already initialized
	for name in ("capsuleInstPanel fuelBar stageNumbers stagePanelBlank " +
	  "stagePanelDecoupler stagePanelFuel").split
		img = file.loadImage("/usr/pics/UI/" + name + ".png")
		qa.assert img
		pic[name] = img
	end for
	
	pic.stageNums = [null]
	w = pic.stageNumbers.width / 8
	h = pic.stageNumbers.height
	for i in range(1, 8)
		pic.stageNums.push pic.stageNumbers.getImage((i-1)*w, 0, w, h)
	end for

	pic.stagePanelByType = {}
	pic.stagePanelByType[StageType.NONE] = pic.stagePanelBlank
	pic.stagePanelByType[StageType.ENGINE] = pic.stagePanelFuel
	pic.stagePanelByType[StageType.DECOUPLER] = pic.stagePanelDecoupler
	pic.stagePanelByType[StageType.CHUTES] = pic.stagePanelBlank // ToDo
	
	outer.panelLeft = 960 - pic.capsuleInstPanel.width

	// Setting up numbers for altitude and speed
	for i in range(0, 5)
		num = new UINumber.Number
		num.y = 618
		num.x = 754 + (17 * i) + (8 * (i >= 3))
		displays.hudSprites.sprites.push num
		outer.altSprites.push num
	end for

	altS = new UISigns.Sign
	altS.y = 610
	altS.x = 865
	altS.setSign "m"

	displays.hudSprites.sprites.push altS
	uiSigns.push altS

end function


drawStagePanel = function(num1to8)
	stage = ship.stages[num1to8]
	x = 120 * (num1to8 - 1)
	g = displays.hud
	g.drawImage pic.stagePanelByType[stage.type], x, 0
	if stage.type == StageType.ENGINE then
		w = pic.fuelBar.width * stage.fuelPct/100
		h = pic.fuelBar.height
		g.drawImage pic.fuelBar, 21, 5, w, h, 0, 0, w, h
	end if
	g.drawImage pic.stageNums[num1to8], x+1, 3, -1, -1, 0, 0, -1, -1, "#AAAAAA"
end function

draw = function(demoMode=false)
	displays.hud.drawImage pic.capsuleInstPanel, panelLeft, 0
	for i in range(1, 8)
		drawStagePanel i
	end for
end function

drawShipInfo = function(spd, alt)
	// Altitude calculation
	altSign = ""

	alt = abs(alt)

	if alt < 1000 then
		altStr = str(round(alt, 3))
		altSign = "m"
	else if alt/1000 < 1000 then
		altStr = str(round(alt/1000, 3))
		altSign = "km"
	else
		altStr = str(round(alt/1000/1000, 3))
		altSign = "Mkm"
	end if

	// Add 0 before
	// str = "0" * (3 - t.len) + str

	// Add 0 after
	// str = t + "0" * (3 - t.len)

	spl = altStr.split(".")

	spl[0] = "0" * (3 - spl[0].len) + spl[0]
	if spl.len > 1 then
		spl[1] = spl[1] + "0" * (3 - spl[1].len)

		finalAlt = spl[0] + spl[1]
	else
		finalAlt = spl[0] + "000"
	end if

	// Speed calculation

	// Drawing stats
	i = 0
	for s in finalAlt
		altSprites[i].setNumber s
		i += 1
	end for

	uiSigns[0].setSign altSign

end function

if locals == globals then
	displays.setup
	init
	globals.ship = Craft.Make(assembly.standardTestRocket)
	draw true
end if

