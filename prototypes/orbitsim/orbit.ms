// Module to calculate and draw orbits.
import "importUtil"
ensureImport "listUtil"
ensureImport "mathUtil"
ensureImport "worldRenderer"

// Accessors so you can use pos.x as a synonym for pos[0], etc.
// Note that you can only use these to READ the values; do NOT
// use them to assign new values!  You must assign to v[0], v[1], etc.
// (Technically `v.anything = whatever` will always update v[0],
// because MiniScript takes the `val` of whatever's to the right of
// the dot to find the numeric index, and that will always be 0.)
list.x = function; return self[0]; end function
list.y = function; return self[1]; end function

// More 2D list-as-vector functions:
list.magnitude = function
	return sqrt(self[0]^2 +self[1]^2)
end function
list.sqrMagnitude = function
	return self[0]^2 + self[1]^2
end function
list.minus = function(other)
	return [self[0] - other[0], self[1] - other[1]]
end function
list.normalize = function
	m = sqrt(self[0]^2 +self[1]^2)
	if m < 1E-9 then return
	self[0] /= m
	self[1] /= m
end function

// Orbit2D class: represents an orbit around a planet[oid].
globals.Orbit2D = {}
Orbit2D.mu = 0		// G (6.67430E-11) * planet mass in kg
Orbit2D.p = 0		// semi-latus rectum
Orbit2D.e = 0		// eccentricity
Orbit2D.omega = 0	// argument of periapsis (radians)

Orbit2D.compute = function(pos, v, mu)
	self.mu = mu
	rMag = pos.magnitude
	vMag2 = v.sqrMagnitude
	
	// Specific angular momentum (z-component in 2D)
	h = pos.x * v.y - pos.y * v.x
	
	// Eccentricity vector
	//eVec = pos.times(vMag2 - mu / rMag).minus(v.times(pos.dot(v)).times(1/mu))
	eVec = pos.times(vMag2 - mu / rMag).minus(v.times(pos.dot(v)))
	eVec = eVec.times(1/mu)
	self.e = eVec.magnitude
	
	// Semi-latus rectum
	self.p = h * h / mu
	
	// Argument of periapsis (angle of eVec)
	if self.e < 1e-6 then self.omega = 0 else self.omega = atan(eVec.y, eVec.x)
end function

Orbit2D.radiusAtGlobalAngle = function(theta, maxRadius=1E10)
	cosTerm = cos(theta - self.omega)
	denom = 1 + self.e * cosTerm

	if -1E-6 < denom < 1E-6 then return maxRadius
	r = self.p / denom
	if r > maxRadius then r = maxRadius
	if r < -maxRadius then r = -maxRadius
	return r
end function

Orbit2D.pointAtGlobalAngle = function(theta, maxRadius=1E10)
	r = self.radiusAtGlobalAngle(theta, maxRadius)
	return [r * cos(theta), r * sin(theta)]
end function

fullOrbitAnglePoints = range(0, 2*pi, 2*pi/64)
Orbit2D.draw = function(gfx, color="#88FFFF")
	worldRenderer.drawOrbit self, color
end function


// On mu: this is the planet's mass times the gravitational constant,
// in m^3/sec^2.  It scales with the planet mass.  For Earth, the real
// value is about 4E14.  But we'll pick values relative to that, which
// feel about right and are fun to play.
mu_Earth = 4E14
mu_planet = mu_Earth * 0.9

test = function
	// Let's try to set the ship up in a high orbit around the planet.
	alt = 10000*km
	speed = 6300  // (m/sec)

	pos = [0, alt]
	velocity = [speed, 0]
	orbit = new Orbit2D
	orbit.compute pos, velocity, mu_planet
	
	worldRenderer.rocketSprite.rotation = 180
	worldRenderer.rocketPos = pos
	worldRenderer.refScreenPos = [480,500]
	worldRenderer.setup
	worldRenderer.zoomToScaleIdx 11
	worldRenderer.update
	worldRenderer.drawOrbit orbit
	
	globals.orbit = orbit // for debugging
end function


if locals == globals then test
