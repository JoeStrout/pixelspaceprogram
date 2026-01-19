// This module loads static game definition data, e.g. part definitions
// and tech tree nodes.  (Don't confuse this with game *state*, which keeps
// track of the player's progress in a particular playthrough.)
//
// Game data may be loaded dynamically from Google Sheets during development;
// we'll change that to local TSV files when we ship.

import "importUtil"
ensureImport "tsv"

// Use the URL from the "Publish to Web" feature:
baseURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRA2AQx4X9PZyyoU5mMV18MdB-OI50dx-AdShkBqMKqSaa8dFhb3USE5vtUF1JlPBjkTZFouuyF3Quj/pub?output=tsv"
partsListURL = baseURL + "&gid=22599298"
techTreeURL = baseURL + "&gid=1681045610"

nameToKey = function(s)
	return s[0].lower + s[1:].replace(" ", "")
end function

globals.PartDef = {}

PartDef.initFromData = function(data)
	self.name = data.Name
	self.key = nameToKey(self.name)
	self.size = data.Size
	self.ispAtm = data["ISP Atm"]
	self.ispVac = data["ISP Vac"]
	self.thrust = data.Thrust
	self.capacity = data.Capacity
	self.techNode = data["Tech Node"]
	self.anchors = data.Anchors
	self.massFlow = data["Mass Flow"]
	m = data.Mass
	if m.indexOf("-") != null then   // wet mass - dry mass
		parts = m.split("-")
		self.dryMass = parts[1].val
		self.mass = parts[0].val
		self.fuelMass = self.mass - self.dryMass
	else
		self.mass = m.val
	end if
end function

PartDef.MakeFromData = function(data)
	isEngine = data["Category"] == "Engines"
	if isEngine then pd = new EngineDef else pd = new self
	pd.initFromData data
	return pd
end function

PartDef.initFromData = function(data)
	self.name = data.Name
	self.key = nameToKey(self.name)
	self.size = data.Size
	self.capacity = data.Capacity
	self.techNode = data["Tech Node"]
	self.anchors = data.Anchors
	self.massFlow = data["Mass Flow"]
	m = data.Mass
	if m.indexOf("-") != null then   // wet mass - dry mass
		parts = m.split("-")
		self.dryMass = parts[1].val
		self.fuelMass = parts[0].val - self.dryMass
	else
		self.mass = m.val
	end if
end function

PartDef.image = function
	path = "/usr/pics/parts/" + self.key + ".png"
	img = file.loadImage(path)
	if not img then img = Image.create(128, 128, color.silver)
	self.image = img	// cache for speedy future calls
	return img
end function

globals.EngineDef = new PartDef

EngineDef.initFromData = function(data)
	super.initFromData data
	self.ispAtm = data["ISP Atm"]
	self.ispVac = data["ISP Vac"]
	m = data.Mass
	if m.indexOf("-") != null then   // wet mass - dry mass
		parts = m.split("-")
		self.dryMass = parts[1].val
		self.mass = parts[0].val
		self.fuelMass = self.mass - self.dryMass
	else
		self.mass = m.val
	end if
end function

// Thrust (in N) produced by this engine, given atmosphere and throttle
EngineDef.thrust = function(atmosphere=1, throttle=1)
	if self.fuelMass <= 0 then return 0
	isp = mathUtil.lerp(self.ispVac, self.ispAtm, atmosphere)
	return self.massFlow * isp * 9.81 * throttle
end function

globals.TechNode = {}
TechNode.MakeFromData = function(data)
	td = new self
	td.name = data.Node
	td.key = nameToKey(td.name)
	td.tier = data.Tier
	td.description = data.Description
	td.prereqs = data.Prerequisites.split(", ")
	for i in td.prereqs.indexes
		td.prereqs[i] = nameToKey(td.prereqs[i])
	end for
	return td
end function

// Fetch the data with a lazy-load strategy
parts = function
	data = tsv.parse(http.get(partsListURL))
	outer.parts = {}
	for line in data
		pd = PartDef.MakeFromData(line)
		parts[pd.key] = pd
	end for
	return parts
end function

techNodes = function
	data = tsv.parse(http.get(techTreeURL))
	outer.techNodes = {}
	for line in data
		td = TechNode.MakeFromData(line)
		techNodes[td.key] = td
	end for
	return techNodes
end function

// ...or initialize it all at once:
init = function
	parts
	techNodes
end function

if locals == globals then
	init
	print "Read " + parts.len + " parts, such as: "
	pprint parts.values[0]

	print "Read " + techNodes.len + " tech nodes, such as: "
	pprint techNodes.values[0]
end if

