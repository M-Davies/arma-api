//  This file converts the contents of the CfgWeapons, CfgMagazines and CfgGlasses config files to a JSON string

private _jsonClasses = [];
private _debug = "";

// Extract weapon values by scope param
// private _configs = createHashMapFromArray [
//   ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")],
//   ["magazines", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgMagazines")],
//   ["glasses", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgGlasses")]
// ];
private _configs = createHashMapFromArray [
  ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")]
];

// Calculates the type of the config item based off it's rough item type. This can be inaccurate.
getType = { params["_roughItemType"];
  private _subtype = _roughItemType select 1;
  private _typeArr = ["", _subtype];

  private _found = false;
  switch (_roughItemType select 0) do {
    case "Weapon": {
      switch (_subtype) do {
        case "AssaultRifle" || "MachineGun" || "Shotgun" || "Rifle" || "SubmachineGun" || "SniperRifle": {
          _typeArr set [0, "Primaries"];
        };
        case "Handgun": {
          _typeArr set [0, "Secondaries"];
        };
        case "Launcher" || "MissileLauncher" || "RocketLauncher": {
          _typeArr set [0, "Launchers"];
        };
        case "Throw": {
          _typeArr set [0, "Throwables"];
        };
        default {
          _typeArr = false;
        };
      };
    };

    case "Item": {
      switch (_subtype) do {
        case "AccessoryMuzzle": {
          _typeArr set [0, "Muzzles"];
        };
        case "AccessoryPointer": {
          _typeArr set [0, "Pointers"];
        };
        case "AccessorySights": {
          _typeArr set [0, "Optics"];
        };
        case "AccessoryBipod": {
          _typeArr set [0, "Bipods"];
        };
        default {
          _typeArr = false;
        };
      };
    };

    case "Equipment": {

    };

    case "Magazine": {

    };

    case "Mine": {

    };

    default {
      if (_roughItemType select 0 == "VehicleWeapon") {
        // Pass up stack to continue the loop
        _typeArr = false;
      } else {
        // No matching type was found and it isn't an excluded one
        throw "[ERROR] Unknown type: " + _roughItemType select 0;
      };
    };
  };

  _typeArr;
};

// Calculates the mod of the config item based off the author
getModName = { params["_author"];
  private _modName = "";

  // I would prefer to use an else if here but it doesn't exist in sqf seemingly
  private _found = false;
  if (["Bohemia Interactive", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "vanilla";
    _found = true;
  };
  if (["ACE", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "ace";
    _found = true;
  };
  if (["3commandobrigade", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "3cb";
    _found = true;
  };
  if (["Red Hammer Studios", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "rhs";
    _found = true;
  };
  if (["Toadie", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "niarms";
    _found = true;
  };
  if (["zabb", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "tacvests";
    _found = true;
  };
  if (["VanSchmoozin", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "vsm";
    _found = true;
  };
  if (["da12thMonkey", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "rksl";
    _found = true;
  };
  if (["ACRE2Team", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "acre";
    _found = true;
  };
  if (["Project OPFOR", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "projectopfor";
    _found = true;
  };
  if (["Rebel", _author] call BIS_fnc_inString && _found == false) then {
    _modName = "immersioncigs";
    _found = true;
  };

  // Not found, either author is unknown or is not supported yet
  if (_author != "" && _found == false); {
    throw "[ERROR] Unrecognised author name: " + _author;
  };

  _modName;
};

// Iterate over config files
{
  private _configArray = "";
  switch (_x) do {

    case "weapons": {
      _configArray = _y apply {
        private _configName = configName _x;
        private _type = [_configName call BIS_fnc_itemType] call getType;
        if (_type == false) {
          continue;
        };

        // Format each hit to a JSON object and strip out chars that interfere with JSON parsing
        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "magazines":%10,%11    "type":"%12",%13    "subtype":"%14",%15    "mod":"%16",%17,    "weight":"%18",%19    "magwell":%20%21  },%22',
          endl,
          _configName,
          endl,
          [[getText (_x >> "displayName"), "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
          endl,
          [[getText (_x >> "descriptionShort"),  "\", ""] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace,
          endl,
          [getText (_x >> "Picture"), "\", "\\"] call CBA_fnc_replace,
          endl,
          getArray (_x >> "magazines") apply {_x}, // Note: _x is block specific
          endl,
          _type select 0,
          endl,
          _type select 1,
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

    // TODO: Will need to update the getType function to support these two configs
    case "magazines": {
      _configArray = _y apply {
        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "ammo":%10,%11    "count":%12,%13    "mod":"%14",%15    "weight":"%16",%17    "type":"Magazines"%18  },%19',
          endl,
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
          endl,
          endl
        ];
      };
    };

    default {
      _configArray = _y apply {
        format [
          '  {%1    "class":"%2",%3    "name":"%4",%5    "description":"%6",%7    "image":"%8",%9    "mod":"%10",%11    "weight":"%12",%13    "type":"Facewear"%14  },%15',
          endl,
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
          endl,
          endl
        ];
      };
    };
  };

  // Concatenate all collected objects and add to json array
  //_jsonClasses append _configArray;

} forEach _configs;

// Copy and return
_debug
// private _joinedClasses = (_jsonClasses joinString ",") + endl;
// _jsonString = format ["[%1  %2%3]", endl, _joinedClasses, endl];
// copyToClipboard _jsonString;
// _jsonString
