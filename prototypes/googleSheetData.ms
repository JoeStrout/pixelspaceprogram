// Prototype of accessing our game data directly from
// Google Sheets.  This is useful during development,
// for rapidly iterating on the game details.

import "tsv"

// Use the URL from the "Publish to Web" feature:
baseURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vRA2AQx4X9PZyyoU5mMV18MdB-OI50dx-AdShkBqMKqSaa8dFhb3USE5vtUF1JlPBjkTZFouuyF3Quj/pub?output=tsv"
partsListURL = baseURL + "&gid=22599298"
techTreeURL = baseURL + "&gid=1681045610"

// Fetch the data
partsData = tsv.parse(http.get(partsListURL))
print "Read " + partsData.len + " parts, such as: "
pprint partsData[0]

techData = tsv.parse(http.get(techTreeURL))
print "Read " + techData.len + " tech nodes, such as: "
pprint techData[0]

