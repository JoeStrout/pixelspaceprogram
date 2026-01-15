// Module to draw the planet(s) at any scale.

import "importUtil"
ensureImport "listUtil"
import "LookupTable"
ensureImport "displays"


// Handy units:
globals.cm = 0.01
globals.m = 1
globals.km = 1000

// to check collisions
visiblePoly = []

// Constants:
worldRadius = 6000*km

// Terrain shape functions (lookup tables):
terrain0 = LookupTable.Make([0,0,0.3,0.31,0.4,0.4,0.1,0.1,0.1,-0.2,-0.5,-0.5,-1,-0.2,0])
terrain1 = LookupTable.Make([0,0,0.1,0.2,0.4,0.8,1,0.8,0.8,0.5,0.2,0,0,-0.5,-1,-0.5,0])
terrain2 = LookupTable.Make([0,0.1,0.3,0.2,0.1,0,0,0.2,0.1,0.3,0.3,0.3,0.2,0,0])
terrain3 = LookupTable.Make([0,0,0.4,0.4,1,1,1,1,0.6,0.6,0.6,0.5,0.4,0.3,0.2,0,0])


// Main scale control:
scales = [10*cm, 25*cm, 50*cm, m, 3*m, 10*m, 30*m, 100*m, 300*m, km,
  3*km, 10*km, 30*km, 100*km, 300*km, 1000*km]
scaleIdx = 0
pixelScale = scales[scaleIdx]  // m per pixel

rocketIcon = file.loadImage("/usr/pics/rocketIcon.png")

rocketSprite = new Sprite
rocketSprite.image = null
// Note: rocket is ~500 pixels tall, and is assumed to
// be 50 meters tall.  So its native scale is:
rocketSprite.imageScale = 0.1 // m/pixel

// examples:
// scale=1 --> 500 pixels tall --> 0.1 m/pixel
// scale=0.1 --> 50 pixels tall --> 1 m/pixel
// scale=0.01 --> 5 pixels tall --> 10 m/pixel


drawCircle = function(screenCenter, screenRadius, color)
	left = screenCenter[0] - screenRadius
	bottom = screenCenter[1] - screenRadius
	diam = screenRadius * 2
	displays.exterior.fillEllipse left, bottom, diam, diam, color	  
end function

// worldToScreen: given an [x,y] position in absolute (meter) coordinates,
// return the corresponding screen (pixel) coordinates.
worldToScreen = function(pos)
	return [
		(pos[0] - rocketPos[0]) / pixelScale + refScreenPos[0],
		(pos[1] - rocketPos[1]) / pixelScale + refScreenPos[1] ]
end function

// drawWorld: draw the world, relative to a reference
// position (usually the player position).  Given:
//   refScreenPos: [x,y] of the reference on screen (pixels)
//   refWorldPos: [x,y] of the reference relative to the
//     center of the world (meters)
drawWorld = function(refScreenPos, refWorldPos)
	worldCtrPix = [
	  refScreenPos[0] + refWorldPos[0] / pixelScale,
	  refScreenPos[1] + refWorldPos[1] / pixelScale ]
	displays.exterior.clear color.clear
	worldRadPix = worldRadius / pixelScale
	
	if pixelScale <= 100*km then
		// atmosphere:
		drawCircle worldCtrPix, 
		  worldRadPix + 100*km / pixelScale, "#000066"		
		drawCircle worldCtrPix, 
		  worldRadPix + 50*km / pixelScale, "#6633FF"
		drawCircle worldCtrPix, 
		  worldRadPix + 25*km / pixelScale, "#AAAAFF"		
	end if
	// ground:
	if pixelScale >= 3000 then
		drawCircle worldCtrPix, worldRadPix, color.green
	else
		drawTerrain worldCtrPix
	end if
end function

// drawTerrain: draw the visible section of the ground by actually
// sampling the terrain height along the visible arc, and drawing
// it as a polygon.
drawTerrain = function(worldCtrPix)
	x = worldCtrPix[0]; y = worldCtrPix[1]
	radRange = getVisibleAngleRange  // angle range, in radians
	poly = []
	ang = radRange[0]
	dang = (radRange[1] - radRange[0]) / 100
	while ang < radRange[1]
		r = worldRadiusAtAngle(ang) / pixelScale
		poly.push [x + r * cos(ang), y + r * sin(ang)]
		ang += dang
	end while
	poly.push [poly[-1][0], 0]
	poly.push [poly[0][0], 0]
	displays.exterior.fillPoly poly, color.green

	outer.visiblePoly = poly
end function

worldRadiusAtAngle = function(angleInRadians)
	return worldRadius + 
	   terrain0.lookup(angleInRadians*10) * 10*km +
	   terrain1.lookup(angleInRadians*100) * km +
	   terrain2.lookup(angleInRadians*10000) * 100 +
	   terrain3.lookup(angleInRadians*100000) * 10 +
	   terrain3.lookup(angleInRadians*1000001) * 1
end function

// drawRocket: draw our rocket, at the given screen position
// and current scale.  If we're zoomed too far out, switch
// to a constant-size icon.
drawRocket = function(refScreenPos)
	rocketSprite.x = refScreenPos[0]
	rocketSprite.y = refScreenPos[1]
	imgScale = rocketSprite.imageScale / pixelScale
	if pixelScale <= 1 then
		rocketSprite.scale = imgScale
		rocketSprite.image = ship.image
	else
		rocketSprite.scale = 1
		rocketSprite.image = rocketIcon
	end if
end function

drawScaleBar = function
	displays.exterior.line 10, 630, 10+50, 630, color.white, 3
	barSize = 50 * pixelScale
	if barSize >= km then
		s = str(round(barSize/km, 2)) + " km"
	else if barSize >= m then
		s = str(round(barSize, 2)) + " m"
	else
		s = str(round(barSize/cm, 2)) + " cm"
	end if
	displays.exterior.print s, 10, 615, color.white, "small"
end function

// screenToWorld: inverse of worldToScreen, converts screen pixel
// coordinates back to absolute (meter) world coordinates.
screenToWorld = function(screenPos)
	return [
		(screenPos[0] - refScreenPos[0]) * pixelScale + rocketPos[0],
		(screenPos[1] - refScreenPos[1]) * pixelScale + rocketPos[1] ]
end function

// getVisibleAngleRange: calculate the range of orbit angles that could
// be visible on screen. Returns [minAngle, maxAngle], with a safety margin
// to ensure we never underestimate. The range may span more than 2π if needed.
getVisibleAngleRange = function
	// Get screen corners in world coordinates
	corners = [
		screenToWorld([0, 0]),
		screenToWorld([960, 0]),
		screenToWorld([960, 640]),
		screenToWorld([0, 640]) ]

	// Calculate angle from orbit center [0,0] to each corner
	angles = []
	for corner in corners
		angle = atan(corner[1], corner[0])
		angles.push angle
	end for

	// Find min and max angles
	minAngle = angles[0]
	maxAngle = angles[0]
	for angle in angles
		if angle < minAngle then minAngle = angle
		if angle > maxAngle then maxAngle = angle
	end for

	// Handle wraparound: if the range is > π, we might be crossing 0
	// In that case, check if going the "other way" gives a smaller range
	span = maxAngle - minAngle
	if span > pi then
		// Try the other direction (crossing through 0/2π)
		// Normalize all angles to [0, 2π)
		normalized = []
		for angle in angles
			a = angle
			while a < 0
				a = a + 2*pi
			end while
			while a >= 2*pi
				a = a - 2*pi
			end while
			normalized.push a
		end for

		minAngle = normalized[0]
		maxAngle = normalized[0]
		for angle in normalized
			if angle < minAngle then minAngle = angle
			if angle > maxAngle then maxAngle = angle
		end for

		span = maxAngle - minAngle
		// If it's still > π, we're seeing more than half the orbit
		if span > pi then
			// Just draw the whole orbit
			return [0, 2*pi]
		end if
	end if

	// Add 30% safety margin on each side (never underestimate)
	margin = span * 0.3
	minAngle = minAngle - margin
	maxAngle = maxAngle + margin

	return [minAngle, maxAngle]
end function

// getValidOrbitAngleRange: returns the range of angles where the orbit
// mathematically exists. For elliptical orbits (e < 1), this is the full
// circle. For hyperbolic/parabolic orbits (e >= 1), this is limited by
// the asymptotes.
getValidOrbitAngleRange = function(orbit)
	if orbit.e < 0.9999 then
		// Elliptical orbit - valid everywhere
		return [null, null]  // null means unbounded
	end if

	// Hyperbolic or parabolic orbit
	// The orbit exists only where 1 + e*cos(theta - omega) > 0
	// This means cos(theta - omega) > -1/e
	// So |theta - omega| < arccos(-1/e)

	if orbit.e >= 1 then
		maxTrueAnomaly = acos(-1 / orbit.e)
	else
		// Nearly parabolic (e very close to 1)
		maxTrueAnomaly = acos(-1 / orbit.e)
	end if

	// Convert from true anomaly to global angle
	minAngle = orbit.omega - maxTrueAnomaly
	maxAngle = orbit.omega + maxTrueAnomaly

	return [minAngle, maxAngle]
end function

// intersectAngleRanges: find the intersection of two angle ranges [min, max].
//
// Key insight: angles wrap every 2π, so [0, 1] and [2π, 2π+1] represent the same arc.
// To intersect two ranges that might be in different "wraps", we:
// 1. Shift range1 by multiples of 2π to align it with range2
// 2. Then do a simple interval intersection
//
// Algorithm:
// - Shift range1's minimum to be within π of range2's minimum (same 2π period)
// - Shift range1's maximum by the same amount (preserves the arc)
// - Intersect as simple intervals [min, max]
//
// Returns the intersection [min, max], or null if no overlap.
// ToDo: move this to some general math module.
intersectAngleRanges = function(range1, range2)
	// If range2 is unbounded (null for elliptical orbits), return range1
	if range2[0] == null then return range1

	min1 = range1[0]
	max1 = range1[1]
	min2 = range2[0]
	max2 = range2[1]

	span1 = max1 - min1
	span2 = max2 - min2

	// If either range spans >= 2π, it covers the full circle
	// So the intersection is just the other range
	if span1 >= 2*pi then return range2
	if span2 >= 2*pi then return range1

	// Calculate how much to shift range1 to align it with range2
	// We want min1 + shift to be within π of min2
	shift = 0
	while min1 + shift < min2 - pi
		shift += 2*pi
	end while
	while min1 + shift > min2 + pi
		shift -= 2*pi
	end while

	// Apply the shift to both endpoints of range1
	min1 += shift
	max1 += shift

	// Now both ranges are aligned - do simple interval intersection
	intMin = min1
	if min2 > intMin then intMin = min2

	intMax = max1
	if max2 < intMax then intMax = max2

	// Check for overlap
	if intMin >= intMax then return null

	return [intMin, intMax]
end function

drawOrbit = function(orbit, color="#88FFFF")
	if not orbit.isValid then return
	
	// Calculate which portion of the orbit is visible on screen
	visibleRange = getVisibleAngleRange

	// Get the valid angle range (unbounded for elliptical, limited for hyperbolic)
	validRange = getValidOrbitAngleRange(orbit)

	// Intersect visible and valid ranges
	drawRange = intersectAngleRanges(visibleRange, validRange)

	if drawRange == null then return  // No visible orbit on screen

	minAngle = drawRange[0]
	maxAngle = drawRange[1]

	// Generate 64 evenly-spaced angles within the draw range
	angleStep = (maxAngle - minAngle) / 64

	lastPoint = null
	for i in range(0, 64)
		theta = minAngle + i * angleStep
		// get the point, in absolute (meter) units
		point = orbit.pointAtGlobalAngle(theta)
		// convert to display units
		point = worldToScreen(point)
		// then draw!
		if lastPoint != null then displays.exterior.line lastPoint.x, lastPoint.y, point.x, point.y, color
		lastPoint = point
	end for
end function

zoomToScaleIdx = function(scaleIdx)
	if scaleIdx < 0 then scaleIdx = 0
	if scaleIdx >= scales.len then scaleIdx = scales.len - 1
	outer.scaleIdx = scaleIdx
	outer.pixelScale = scales[scaleIdx]
end function	

zoomOut = function; zoomToScaleIdx scaleIdx + 1; end function
zoomIn  = function; zoomToScaleIdx scaleIdx - 1; end function

rocketPos = [0, worldRadiusAtAngle(pi/2)+25]  // position of the rocket in the world, in meters
refScreenPos = [480, 200]  // position of the rocket on screen, in pixels

setup = function
	displays.outerSprites.sprites.push rocketSprite
end function

update = function
	drawWorld refScreenPos, [-rocketPos[0], -rocketPos[1]]
	drawRocket refScreenPos
	drawScaleBar
	
//	visRange = getVisibleAngleRange
//	visRangeDeg = visRange.times(180/pi)
//	text.row = 25; text.column = 40; print visRangeDeg
end function

runUnitTests = function
	import "qa"

	// Basic partial overlap cases
	qa.assert intersectAngleRanges([0, 1], [0, 1.5]) == [0, 1]
	qa.assert intersectAngleRanges([0, 1.5], [0, 1]) == [0, 1]
	qa.assert intersectAngleRanges([-1, 0], [-1.5, 0]) == [-1, 0]
	qa.assert intersectAngleRanges([0, 2], [1, 3]) == [1, 2]
	qa.assert intersectAngleRanges([1, 3], [0, 2]) == [1, 2]

	// Complete containment (one range entirely inside the other)
	qa.assert intersectAngleRanges([0, 1], [-1, 2]) == [0, 1]
	qa.assert intersectAngleRanges([-1, 2], [0, 1]) == [0, 1]

	// No overlap cases (should return null)
	qa.assert intersectAngleRanges([0, 1], [2, 3]) == null
	qa.assert intersectAngleRanges([2, 3], [0, 1]) == null
	qa.assert intersectAngleRanges([-3, -2], [1, 2]) == null

	// Exact overlap (same range)
	qa.assert intersectAngleRanges([0, 1], [0, 1]) == [0, 1]
	qa.assert intersectAngleRanges([1, 2], [1, 2]) == [1, 2]

	// Wraparound cases: ranges in different 2π periods representing same arcs
	// Note: result is always in range2's (2nd argument's) coordinate space
	qa.assert intersectAngleRanges([0, 1], [2*pi, 2*pi+1]) == [2*pi, 2*pi+1]
	qa.assert intersectAngleRanges([2*pi, 2*pi+1], [0, 1]) == [0, 1]
	qa.assert intersectAngleRanges([-pi, -pi+1], [pi, pi+1]) == [pi, pi+1]

	// Wraparound: partial overlap across different periods
	qa.assert intersectAngleRanges([0, 1], [2*pi-0.5, 2*pi+0.5]) == [2*pi, 2*pi+0.5]
	qa.assert intersectAngleRanges([2*pi-0.5, 2*pi+0.5], [0, 1]) == [0, 0.5]

	// Range spanning full circle (>= 2π)
	qa.assert intersectAngleRanges([0, 2*pi], [1, 2]) == [1, 2]
	qa.assert intersectAngleRanges([1, 2], [0, 2*pi]) == [1, 2]
	qa.assert intersectAngleRanges([-1, 0], [0, 2*pi]) == [-1, 0]
	qa.assert intersectAngleRanges([0, 2*pi+1], [1, 2]) == [1, 2]

	// Both ranges span full circle
	qa.assert intersectAngleRanges([0, 2*pi], [-1, 2*pi-1]) == [-1, 2*pi-1]

	// Unbounded range (null = elliptical orbit case)
	qa.assert intersectAngleRanges([0, 1], [null, null]) == [0, 1]
	qa.assert intersectAngleRanges([-1, 1], [null, null]) == [-1, 1]

	print "All intersectAngleRanges tests passed!"
end function

if locals == globals then
	runUnitTests
	displays.setup
	setup
	rocketSprite.rotation = 90
	while true
		update
		k = key.get.code
		if k == 17 or k == 20 then
			zoomOut
		else if k == 18 or k == 19 then
			zoomIn
		else if k == 27 or char(k) == "q" then
			break
		end if
		
	end while
	text.row = 4
end if
