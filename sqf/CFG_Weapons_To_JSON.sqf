//  This file converts the contents of the CfgWeapons config file to a JSON string similar to the below
//  {
//    "rhsgref_weap_savz58v_black_rxo1":{
//      "displayName":"Sa vz. 58V (Rail, Black)",
//      "description":"Assault rifle <br/>Caliber: 7.62x39 mm",
//      "image":"\\rhsgref\\addons\\rhsgref_inventoryicons\\data\\weapons\\rhs_weap_savz58v_rail_black_ca.paa",
//      "magazines":["rhs_30Rnd_762x39mm_Savz58","rhs_30Rnd_762x39mm_Savz58_tracer"]
//    },
//    ...
//  }

// Extract weapon values by scope param
private _configs = "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons");

// Format each hit to a JSON object and strip out chars that interfere with JSON parsing
private _configText = _configs apply {format ['  "%1":{%2    "displayName":"%3",%4    "description":"%5",%6    "image":"%7",%8    "magazines":%9%10  }',
  configName _x,
  endl,
  [[getText (_x >> "displayName"), "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
  endl,
  [[getText (_x >> "descriptionShort"),  "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
  endl,
  [getText (_x >> "Picture"), "\", "\\"] call CBA_fnc_replace,
  endl,
  getArray (_x >> "magazines") apply {_x}, // Note: _x is block specific
  endl,
  endl
]};

// Concatenate all objects and add closing/opening remarks
private _joined = _configText joinString "," + endl;
private _output = "{" + endl + _joined + endl + "}";
copyToClipboard _output;
_output
