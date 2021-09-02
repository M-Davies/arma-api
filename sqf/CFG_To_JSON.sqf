//  This file converts the contents of the key cfg config files to a JSON string

private _jsonClasses = [];

// Extract weapon values by scope param
private _CONFIGS = createHashMapFromArray [
  ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")],
  ["magazines", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgMagazines")],
  ["vehicles", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgVehicles")],
  ["glasses", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgGlasses")]
];

// Calculates the type and subtype of the config item based off it's rough item return. This can be inaccurate.
getType = { params["_ROUGHTYPE"];
  private _SUBTYPE = _ROUGHTYPE select 1;
  private _TYPEARRAY = ["", _SUBTYPE];

  switch (_ROUGHTYPE select 0) do {
    case "Weapon": {
      switch (_SUBTYPE) do {
        case "AssaultRifle" || "MachineGun" || "Shotgun" || "Rifle" || "SubmachineGun" || "SniperRifle": {
          _TYPEARRAY set [0, "Primaries"];
        };
        case "Handgun": {
          _TYPEARRAY set [0, "Secondaries"];
        };
        case "Launcher" || "MissileLauncher" || "RocketLauncher": {
          _TYPEARRAY set [0, "Launchers"];
        };
        case "Throw": {
          _TYPEARRAY set [0, "Throwables"];
        };
        default {
          _TYPEARRAY = false;
        };
      };
    };

    case "Item": {
      switch (_SUBTYPE) do {
        case "AccessoryMuzzle": {
          _TYPEARRAY set [0, "Muzzles"];
        };
        case "AccessoryPointer": {
          _TYPEARRAY set [0, "Pointers"];
        };
        case "AccessorySights": {
          _TYPEARRAY set [0, "Optics"];
        };
        case "AccessoryBipod": {
          _TYPEARRAY set [0, "Bipods"];
        };
        case "Binocular" || "LaserDesignator": {
          _TYPEARRAY set [0, "Binoculars"];
        };
        case "Compass": {
          _TYPEARRAY set [0, "Compasses"];
        };
        case "FirstAidKit" || "Medikit" || "MineDetector" || "Toolkit": {
          _TYPEARRAY set [0, "Tools"];
        };
        case "GPS": {
          _TYPEARRAY set [0, "GPSs"];
        };
        case "NVGoggles": {
          _TYPEARRAY set [0, "Goggles"];
        };
        case "Radio": {
          _TYPEARRAY set [0, "Radios"];
        };
        case "UAVTerminal": {
          _TYPEARRAY set [0, "Terminals"];
        };
        case "Watch": {
          _TYPEARRAY set [0, "Watches"];
        };
        default {
          _TYPEARRAY = false;
        };
      };
    };

    case "Equipment": {
      switch (_SUBTYPE) do {
        case "Glasses": {
          _TYPEARRAY set [0, "Facewear"];
        };
        case "Headgear": {
          _TYPEARRAY set [0, "Headgear"];
        };
        case "Vest": {
          _TYPEARRAY set [0, "Vests"];
        };
        case "Uniform": {
          _TYPEARRAY set [0, "Uniforms"];
        };
        case "Backpack": {
          _TYPEARRAY set [0, "Backpacks"];
        };
        default {
          // The above SHOULD be the only valid types
          throw "[ERROR] Unknown equipment subtype: " + _SUBTYPE;
        };
      };
    };

    case "Magazine": {
      switch (_SUBTYPE) do {
        case "Artillery" || "CounterMeasures" || "UnknownMagazine": {
          _TYPEARRAY = false;
        };
        default {
          // The above SHOULD be the only non-arsenal types
          _TYPEARRAY set [0, "Magazines"];
        };
      };
    };

    case "Mine": {
      switch (_SUBTYPE) do {
        case "Mine" || "MineBounding" || "MineDirectional": {
          _TYPEARRAY set [0, "Explosives"];
        };
        default {
          // The above SHOULD be the only valid types
          throw "[ERROR] Unknown mine subtype: " + _SUBTYPE;
        };
      };
    };

    default {
      if (_ROUGHTYPE select 0 == "VehicleWeapon") {
        // Pass up stack to continue the loop
        _TYPEARRAY = false;
      } else {
        // No matching type was found and it isn't an excluded one
        throw "[ERROR] Unknown type: " + _ROUGHTYPE select 0;
      };
    };
  };

  _TYPEARRAY;
};

// Calculates the mod of the config item based off the author
getModName = { params["_AUTHOR"];
  private _modName = "";

  // I would prefer to use an else if here but it doesn't exist in sqf seemingly
  private _found = false;
  if (["Bohemia Interactive", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "vanilla";
    _found = true;
  };
  if (["ACE", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "ace";
    _found = true;
  };
  if (["3commandobrigade", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "3cb";
    _found = true;
  };
  if (["Red Hammer Studios", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "rhs";
    _found = true;
  };
  if (["Toadie", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "niarms";
    _found = true;
  };
  if (["zabb", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "tacvests";
    _found = true;
  };
  if (["VanSchmoozin", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "vsm";
    _found = true;
  };
  if (["da12thMonkey", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "rksl";
    _found = true;
  };
  if (["ACRE2Team", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "acre";
    _found = true;
  };
  if (["Project OPFOR", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "projectopfor";
    _found = true;
  };
  if (["Rebel", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "immersioncigs";
    _found = true;
  };

  // Not found, either author is unknown or is not supported yet
  if (_AUTHOR != "" && _found == false); {
    throw "[ERROR] Unrecognised author name: " + _AUTHOR;
  };

  _modName;
};

// START: Iterate over config files
{
  private _CONFIGARRAY = [];
  switch (_x) do {

    case "weapons": {
      _CONFIGARRAY = _y apply {
        private _CONFIGNAME = configName _x;
        private _TYPE = [_CONFIGNAME call BIS_fnc_itemType] call getType;
        if (_TYPE == false) {
          continue;
        };

        // Format each hit to a JSON object and strip out chars that interfere with JSON parsing
        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "magazines":%10,%11    "type":"%12",%13    "subtype":"%14",%15    "mod":"%16",%17,    "weight":"%18",%19    "magwell":%20%21  },%22',
          endl,
          _CONFIGNAME,
          endl,
          [[getText (_x >> "displayName"), "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
          endl,
          [[getText (_x >> "descriptionShort"),  "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
          endl,
          [getText (_x >> "Picture"), "\", "\\"] call CBA_fnc_replace,
          endl,
          getArray (_x >> "magazines") apply {_x}, // Note: _x is block specific
          endl,
          _TYPE select 0,
          endl,
          _TYPE select 1,
          endl,
          [getText (_x >> "author")] call getModName,
          endl,
          getNumber (_x >> "mass"),
          endl,
          getArray (_x >> "magazineWell") apply {_x},
          endl,
          endl
        ];
      };
    };

    case "magazines": {
      _CONFIGARRAY = _y apply {
        private _CONFIGNAME = configName _x;
        private _TYPE = [_CONFIGNAME call BIS_fnc_itemType] call getType;
        if (_TYPE == false) {
          continue;
        };

        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "ammo":%10,%11    "count":%12,%13    "mod":"%14",%15    "weight":"%16",%17    "type":"%18",%19    "subtype":"%20"%21  },%22',
          endl,
          _CONFIGNAME,
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
          _TYPE select 0,
          endl,
          _TYPE select 1,
          endl,
          endl
        ];
      };
    };

    case "vehicles": {
      _CONFIGARRAY = _y apply {
        private _CONFIGNAME = configName _x;
        private _TYPE = [_CONFIGNAME call BIS_fnc_itemType] call getType;
        if (_TYPE == false) {
          continue;
        };

        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9        "mod":"%10",%11    "weight":"%12",%13    "type":"%14",%15    "subtype":"%16"%17  },%18',
          endl,
          _CONFIGNAME,
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
          _TYPE select 0,
          endl,
          _TYPE select 1,
          endl,
          endl
        ];
      };
    };

    default {
      _CONFIGARRAY = _y apply {
        private _CONFIGNAME = configName _x;
        private _TYPE = [_CONFIGNAME call BIS_fnc_itemType] call getType;
        if (_TYPE == false) {
          continue;
        };

        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "mod":"%10",%11    "weight":"%12",%13    "type":"%14",%15    "type":"%16"%17  },%18',
          endl,
          _CONFIGNAME,
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
          _TYPE select 0,
          endl,
          _TYPE select 1,
          endl,
          endl
        ];
      };
    };
  };

  // Concatenate all collected objects and add to json array
  _jsonClasses append _CONFIGARRAY;

} forEach _CONFIGS;

// Copy and return
private _joinedClasses = (_jsonClasses joinString ",") + endl;
_JSON = format ["[%1  %2%3]", endl, _joinedClasses, endl];
copyToClipboard _JSON;
_JSON
