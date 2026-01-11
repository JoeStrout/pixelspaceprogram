// Engine Calculator
// Calculates derived properties from fundamental engine specs

g0 = 9.81  // standard gravity, m/s²

// Natural log (MiniScript's log is base-10)
ln = function(x); return log(x) * 2.302585; end function

// Input fundamental properties
print "=== Engine Calculator ==="
print

dryMass = input("Dry mass (kg): ").val
fuelMass = input("Fuel mass (kg): ").val
ispSL = input("Sea-level Isp (s): ").val
ispVac = input("Vacuum Isp (s): ").val
massFlow = input("Mass flow rate (kg/s): ").val
payloadMass = input("Payload/craft mass (kg): ").val

// Calculate derived values
wetMass = dryMass + fuelMass
thrustSL = massFlow * ispSL * g0
thrustVac = massFlow * ispVac * g0
burnTime = fuelMass / massFlow

// Delta-V calculation (Tsiolkovsky rocket equation)
initialMass = payloadMass + wetMass
finalMass = payloadMass + dryMass
deltaVSL = ispSL * g0 * ln(initialMass / finalMass)
deltaVVac = ispVac * g0 * ln(initialMass / finalMass)

// TWR (thrust-to-weight ratio) at launch
totalWetMass = payloadMass + wetMass
twrSL = thrustSL / (totalWetMass * g0)
twrVac = thrustVac / (totalWetMass * g0)

// Print results
print
print "=== Derived Properties ==="
print "Wet mass:        " + wetMass + " kg"
print "Thrust (SL):     " + round(thrustSL, 1) + " N (" + round(thrustSL/1000, 2) + " kN)"
print "Thrust (Vac):    " + round(thrustVac, 1) + " N (" + round(thrustVac/1000, 2) + " kN)"
print "Burn time:       " + round(burnTime, 1) + " s"
print
print "=== Performance (with " + payloadMass + " kg payload) ==="
print "Mass ratio:      " + round(initialMass / finalMass, 2)
print "TWR at launch:   " + round(twrSL, 2) + " (SL) / " + round(twrVac, 2) + " (Vac)"
print "Delta-V (SL):    " + round(deltaVSL, 0) + " m/s"
print "Delta-V (Vac):   " + round(deltaVVac, 0) + " m/s"
