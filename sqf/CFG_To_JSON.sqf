//  This file converts the contents of the CfgWeapons, CfgMagazines and CfgGlasses config file to a JSON string

private _jsonClasses = "";

// Extract weapon values by scope param
private _configs = createHashMapFromArray [
  ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")],
  ["magazines", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgMagazines")],
  ["glasses", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgGlasses")]
];

// Calculates the mod of the config item based off the author
getModName = { params["_author"];
  private _modName;

  if (_author == "Bohemia Interactive") {
    _modName = "vanilla";
  } else if (["ace", _author] call BIS_fnc_inString) {
    _modName = "ace";
  } else if (["3cb", _author] call BIS_fnc_inString) {
    _modName = "3CB";
  } else if (["rhs", _author] call BIS_fnc_inString) {
    _modName = "Red Hammer Studios";
  } else if (["niarms", _author] call BIS_fnc_inString) {
    _modName = "NIArms";
  } else if (["tac", _author] call BIS_fnc_inString) {
    _modName = "Tac Vests";
  } else if (["vsm", _author] call BIS_fnc_inString) {
    _modName = "VSM";
  } else if (["rksl", _author] call BIS_fnc_inString) {
    _modName = "RKSL Studios";
  } else if (["acre", _author] call BIS_fnc_inString) {
    _modName = "ACRE2";
  } else if (["cigs", _author] call BIS_fnc_inString) {
    _modName = "Immersion Cigs";
  } else {
    throw "[ERROR] Unrecognised author name: " + _author;
  }

  _modName;
}

{
  private _configText;
  if (_x == "weapons") then {
    _configText = _y apply {
      // Calculate weapon type
      private _type = "";
      private _subtype = "";
      switch (getNumber (_x >> "type")) do {
        case == 1: {
          _type = "Weapon";
          _subtype = "Primary";
        };
        case == 2: {
          _type = "Weapon";
          _subtype = "Secondary"; 
        };
        case == 4: {
          _type = "Weapon";
          _subtype = "Launcher";
        };
        case == 605: {
          _type = "Headgear";
        };
        case == 701: {
          _type = "Vest";
        };
        case == 801: {
          _type = "Uniform";
        };
        default {
          // Likely hood this is a not a solider equipable weapon, skip this
          continue;
        };
      };

      private _mod = [getText (_x >> "author")] call getModName;

      // Format each hit to a JSON object and strip out chars that interfere with JSON parsing
      format [
        '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "magazines":%10,%11    "type":"%12",%13    "subtype":"%14",%15    "mod":"%16",%17,    "weight":"%18",%19    "magwell":%20%21  }',
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
        _subtype,
        endl,
        _mod,
        endl,
        getNumber (_x >> "mass"),
        endl,
        getArray (_x >> "magazineWell") apply {_x},
        endl
      ]
    };

    // Concatenate all objects and add closing/opening remarks
    private _joined = _configText joinString "," + endl;
    _jsonClasses = _jsonClasses + format ['  "Weapons" : [%1  %2%3  ],', endl, _joined, endl];
  } else if (_x == "magazines") then {
    _configText = _y apply {
      private _mod = [getText (_x >> "author")] call getModName;
      format [
        '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "ammo":%10,%11    "count":%12,%13    "mod":"%14",%15    "weight":"%16",%17    "type":"Magazine"%18  }',
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
        _mod,
        endl,
        getNumber (_x >> "mass"),
        endl,
        endl
      ]
    };

    // Concatenate all objects and add closing/opening remarks
    private _joined = _configText joinString "," + endl;
    _jsonClasses = _jsonClasses + format ['  "Magazines" : [%1  %2%3  ],', endl, _joined, endl];
  } else {
    _configText = _y apply {
      private _mod = [getText (_x >> "author")] call getModName;
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
        _mod,
        endl,
        getNumber (_x >> "mass"),
        endl,
        endl
      ]
    };

    // Concatenate all objects and add closing/opening remarks
    private _joined = _configText joinString "," + endl;
    _jsonClasses = _jsonClasses + format ['  "Facewear" : [%1  %2%3  ],', endl, _joined, endl];
  }

} forEach _configs;

// Copy and return
_jsonClasses = format ["{%1  %2%3}", endl, _jsonClasses, endl];
copyToClipboard _jsonClasses;
_jsonClasses
