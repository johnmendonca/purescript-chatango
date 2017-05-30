"use strict";

var weights = [
  ["5",  75],  ["6",  75],  ["7",  75],  ["8",  75],
  ["16", 75],  ["17", 75],  ["18", 75],  ["9",  95],
  ["11", 95],  ["12", 95],  ["13", 95],  ["14", 95],
  ["15", 95],  ["19", 110], ["23", 110], ["24", 110],
  ["25", 110], ["26", 110], ["28", 104], ["29", 104],
  ["30", 104], ["31", 104], ["32", 104], ["33", 104],
  ["35", 101], ["36", 101], ["37", 101], ["38", 101],
  ["39", 101], ["40", 101], ["41", 101], ["42", 101],
  ["43", 101], ["44", 101], ["45", 101], ["46", 101],
  ["47", 101], ["48", 101], ["49", 101], ["50", 101],
  ["52", 110], ["53", 110], ["55", 110], ["57", 110],
  ["58", 110], ["59", 110], ["60", 110], ["61", 110],
  ["62", 110], ["63", 110], ["64", 110], ["65", 110],
  ["66", 110], ["68", 95],  ["71", 116], ["72", 116],
  ["73", 116], ["74", 116], ["75", 116], ["76", 116],
  ["77", 116], ["78", 116], ["79", 116], ["80", 116],
  ["81", 116], ["82", 116], ["83", 116], ["84", 116]
]

var totalWeight = 0
weights.forEach(function(w) {
  totalWeight += w[1]
});

// get server name for a given chat group
// "mychatroom" -> "s49"
// uses a mathmatical scheme to distribute names non-alphabetically
exports.groupServer = function(groupName) {
  if (!groupName) return "s5";

  var name = groupName.replace(/[^0-9a-z]/g, 'q');
  var firstFive   = name.substr(0,5);
  var middleThree = name.substr(6,3) || "0rs"; // default "0rs" == 1000 b36

  //base 36 allows any alphanumeric string to parse as int
  var denom = Math.max(parseInt(middleThree, 36), 1000);
  var numer =          parseInt(firstFive, 36);

  // 0.0 - 1.0
  var fraction = (numer % denom) / denom

  var accum = 0;
  for (var i=0; i<weights.length; i++) {
    var w = weights[i];

    accum += w[1] / totalWeight;
    if (accum >= fraction)
      return "s"+w[0];
  }
}

