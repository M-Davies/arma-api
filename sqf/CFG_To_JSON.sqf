//  This file converts the contents of the CfgWeapons, CfgMagazines and CfgGlasses config files to a JSON string

private _jsonClasses = "";

// Extract weapon values by scope param
private _configs = createHashMapFromArray [
  ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")],
  ["magazines", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgMagazines")],
  ["glasses", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgGlasses")]
];

/*
  Calculates the mod of the config item based off the author
*/
getModName = { params["_author"];
  private _modName = "";

  if (["Bohemia Interactive", _author] call BIS_fnc_inString) {
    _modName = "vanilla";
  } else if (["ACE", _author] call BIS_fnc_inString) {
    _modName = "ace";
  } else if (["3commandobrigade", _author] call BIS_fnc_inString) {
    _modName = "3cb";
  } else if (["Red Hammer Studios", _author] call BIS_fnc_inString) {
    _modName = "rhs";
  } else if (["Toadie", _author] call BIS_fnc_inString) {
    _modName = "niarms";
  } else if (["zabb", _author] call BIS_fnc_inString) {
    _modName = "tacvests";
  } else if (["VanSchmoozin", _author] call BIS_fnc_inString) {
    _modName = "vsm";
  } else if (["da12thMonkey", _author] call BIS_fnc_inString) {
    _modName = "rksl";
  } else if (["ACRE2Team", _author] call BIS_fnc_inString) {
    _modName = "acre";
  } else if (["Project OPFOR", _author] call BIS_fnc_inString) {
    _modName = "projectopfor";
  } else if (["Rebel", _author] call BIS_fnc_inString) {
    _modName = "immersioncigs";
  } else {
    if (_author != "") {
      throw "[ERROR] Unrecognised author name: " + _author;
    }
  }

  _modName;
}

// Iterate over config files
{
  private _configText;
  if (_x == "weapons") then {
    _configText = _y apply {
      // Calculate type
      private _type = "";
      switch (getNumber (_x >> "type")) do {
        case == 1: {
          _type = "Primaries";
        };
        case == 2: {
          _type = "Secondaries";
        };
        case == 4: {
          _type = "Launchers";
        };
        case == 605: {
          _type = "Headgear";
        };
        case == 701: {
          _type = "Vests";
        };
        case == 801: {
          _type = "Uniforms";
        };
        default {
          // This is likely not a solider equipable weapon, skip this
          continue;
        };
      };

      // Format each hit to a JSON object and strip out chars that interfere with JSON parsing
      format [
        '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "magazines":%10,%11    "type":"%12",%13    "mod":"%14",%15,    "weight":"%16",%17    "magwell":%18%19  }',
        endl
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
        _type,
        endl,
        [getText (_x >> "author")] call getModName,
        endl,
        getNumber (_x >> "mass"),
        endl,
        getArray (_x >> "magazineWell") apply {_x},
        endl
      ];
    };
  } else if (_x == "magazines") then {
    _configText = _y apply {
      format [
        '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "ammo":%10,%11    "count":%12,%13    "mod":"%14",%15    "weight":"%16",%17    "type":"Magazines"%18  }',
        endl
        configName _x,
        endl,
        [[getText (_x >> "displayName"), "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
        endl,
        [[getText (_x >> "descriptionShort"),  "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
        endl,
        [getText (_x >> "picture"), "\", "\\"] call CBA_fnc_replace,
        endl,
        [[getText (_x >> "ammo"), "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
        endl,
        getNumber (_x >> "count"),
        endl,
        [getText (_x >> "author")] call getModName,
        endl,
        getNumber (_x >> "mass"),
        endl,
        endl
      ];
    };
  } else {
    _configText = _y apply {
      format [
        '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "mod":"%10",%11    "weight":"%12",%13    "type":"Facewear"%14  }',
        endl
        configName _x,
        endl,
        [[getText (_x >> "displayName"), "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
        endl,
        [[getText (_x >> "descriptionShort"),  "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
        endl,
        [getText (_x >> "picture"), "\", "\\"] call CBA_fnc_replace,
        endl,
        [getText (_x >> "author")] call getModName,
        endl,
        getNumber (_x >> "mass"),
        endl,
        endl
      ];
    };
  }

  // Concatenate all collected objects and add to json array
  _jsonClasses = _jsonClasses + _configText joinString "," + endl;

} forEach _configs;

// Copy and return
_jsonClasses = format ["[%1  %2%3]", endl, _jsonClasses, endl];
copyToClipboard _jsonClasses;
_jsonClasses
