// This module implements the "cockpit" or main flight UI:
// the big instrument panel on the right, plus the stage panels.

import "importUtil"
ensureImport "spacecraft"
ensureImport "qa"
ensureImport "displays"

pic = {}

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

if locals == globals then
	displays.setup
	init
	globals.ship = Craft.Make(assembly.standardTestRocket)
	draw true
end if

