// *********************************************
// TITLE: CFG_TO_JSON.sqf
// LICENSE : GNU General Public License v3.0
// DESCRIPTION: This script converts the contents of a key cfg config to a JSON array, which can then be copied from the clipboard and used to populate JSON files, databases or anything else that is required.
// AUTHOR: M-Davies
// USAGE:
//   1) Alter the _CONFIGS hashmap variable to include the config classes you want to add to the json array. Beware of the 10,000,000 limit on array sizes however. You might need to run the config extraction one at a time. See _exampleCONFIGS below for the currently supported configs.
//   2) Run the script in a debug console on arma 3. It may take a few minutes to complete depending on your system specs. Your Arma may hang/not respond during the process, this is normal just be patient.
//   3) You should now have a json array on your clipboard. If it failed to copy for some reason, it should also appear in the debug console's output field.
//   4) It is worth mentioning that the script does not produce 100% valid JSON. This is due to the limitations with CBA and SQF when it comes to parsing and outputting strings. The JSON string that is produced contains leading and trailing quotes, as well as double quotes for nearly every key-value pair declaration (e.g. ["{""formationx"": 10, ""transportsoldier"": 0, ""soundbreathautomatic"": """", ""faction"": ""Default"",...""damagefull"": []}"]). You can clean this up fairly easily with search/replace functionality such as VSCode or by running the "java -jar target/Executer-1.0.0-SNAPSHOT.jar --parse <filename> --output <outfile>" script shipped with the arma-api project.
// *********************************************

// ** SUPPORTED CONFIGS HASHMAP, CHANGE _CONFIGS TO TARGET SPECIFIC CONFIGS FROM THIS LIST **
// private _exampleCONFIGS = createHashMapFromArray [
//   ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")],
//   ["magazines", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgMagazines")],
//   ["vehicles", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgVehicles")],
//   ["glasses", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgGlasses")]
// ];
private _CONFIGS = createHashMapFromArray [
  ["vehicles", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgVehicles")]
];
forceunicode 0;

// Calculates the type and subtype of the config item based off it's rough item return. This can be inaccurate.
getType = { params["_NAME", "_ROUGHTYPE"];
  private _SUBTYPE = _ROUGHTYPE select 1;
  private _TYPEARRAY = [false, _SUBTYPE];
  private _found = false;

  switch (_ROUGHTYPE select 0) do {
    case "Weapon": {
      // Hacky way around making a super long OR conditional
      if (_found == false && ["AssaultRifle", "MachineGun", "Shotgun", "Rifle", "SubmachineGun", "SniperRifle"] find _SUBTYPE != -1) then {
        _TYPEARRAY set [0, "Primaries"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Handgun") then {
        _TYPEARRAY set [0, "Secondaries"];
        _found = true;
      };
      if (_found == false && ["Launcher", "MissileLauncher", "RocketLauncher"] find _SUBTYPE != -1) then {
        _TYPEARRAY set [0, "Launchers"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Throw") then {
        _TYPEARRAY set [0, "Throwables"];
        _found = true;
      };
    };

    case "Item": {
      if (_found == false && _SUBTYPE == "AccessoryMuzzle") then {
        _TYPEARRAY set [0, "Muzzles"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "AccessoryPointer") then {
        _TYPEARRAY set [0, "Pointers"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "AccessorySights") then {
        _TYPEARRAY set [0, "Optics"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "AccessoryBipod") then {
        _TYPEARRAY set [0, "Bipods"];
        _found = true;
      };
      if (_found == false && ["Binocular", "LaserDesignator"] find _SUBTYPE != -1) then {
        _TYPEARRAY set [0, "Binoculars"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Compass") then {
        _TYPEARRAY set [0, "Compasses"];
        _found = true;
      };
      if (_found == false && ["FirstAidKit", "Medikit", "MineDetector", "Toolkit"] find _SUBTYPE != -1) then {
        _TYPEARRAY set [0, "Tools"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "GPS") then {
        _TYPEARRAY set [0, "GPSs"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "NVGoggles") then {
        _TYPEARRAY set [0, "Goggles"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Radio") then {
        _TYPEARRAY set [0, "Radios"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "UAVTerminal") then {
        _TYPEARRAY set [0, "Terminals"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Watch") then {
        _TYPEARRAY set [0, "Watches"];
        _found = true;
      };
    };

    case "Equipment": {
      if (_found == false && _SUBTYPE == "Glasses") then {
        _TYPEARRAY set [0, "Facewear"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Headgear") then {
        _TYPEARRAY set [0, "Headgear"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Vest") then {
        _TYPEARRAY set [0, "Vests"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Uniform") then {
        _TYPEARRAY set [0, "Uniforms"];
        _found = true;
      };
      if (_found == false && _SUBTYPE == "Backpack") then {
        _TYPEARRAY set [0, "Backpacks"];
        _found = true;
      };
      if (_found == false) then {
        // The above SHOULD be the only valid types
        throw format ["[ERROR] CFG_To_JSON.sqf - Unknown equipment subtype: %1 for config: %2", _SUBTYPE, _NAME];
      };
    };

    case "Magazine": {
      // These SHOULD be the only non-arsenal types
      if (["Artillery", "CounterMeasures", "UnknownMagazine"] find _SUBTYPE == -1) then {
        _TYPEARRAY set [0, "Magazines"];
      };
    };

    case "Mine": {
      if (["Mine", "MineBounding", "MineDirectional"] find _SUBTYPE != -1) then {
        _TYPEARRAY set [0, "Explosives"];
      } else {
        // The above SHOULD be the only valid types
        throw format ["[ERROR] CFG_To_JSON.sqf - Unknown mine subtype: %1 for config: %2", _SUBTYPE, _NAME];
      };
    };

    default {
      if (_ROUGHTYPE select 0 != "VehicleWeapon" || [_ROUGHTYPE select 0, "/^ +$/"] call regexMatch != true) then {
        // No matching type was found and it isn't an excluded one
        throw format ["[ERROR] CFG_To_JSON.sqf - Unknown type: %1 for config: %2", _ROUGHTYPE select 0, _NAME];
      };
    };
  };

  _TYPEARRAY
};

// Calculates the mod of the config item based off the author
getModName = { params["_NAME", "_DLC", "_AUTHOR"];
  private _modName = "";

  // I would prefer to use an else if here but it doesn't exist in sqf seemingly
  private _found = false;
  if ((["ACE", _AUTHOR] call BIS_fnc_inString || ["ACE_", _NAME] call BIS_fnc_inString || ["ACE-", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "ace";
    _found = true;
  };
  if ((["3 Commando Brigade", _AUTHOR] call BIS_fnc_inString || ["3commandobrigade", _AUTHOR] call BIS_fnc_inString || ["3CB_", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "3cb";
    _found = true;
  };
  if ((["Red Hammer Studios", _AUTHOR] call BIS_fnc_inString || ["BWMod", _AUTHOR] call BIS_fnc_inString || ["rhs_", _NAME] call BIS_fnc_inString || ["rhsgref_", _NAME] call BIS_fnc_inString || ["RHS_", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "rhs";
    _found = true;
  };
  if ((["Toadie", _AUTHOR] call BIS_fnc_inString || ["Sorry", _AUTHOR] call BIS_fnc_inString || ["Nix", _AUTHOR] call BIS_fnc_inString || ["HLC_Bipod_G36", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "niarms";
    _found = true;
  };
  if (["Ampersand", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "breachingcharge";
    _found = true;
  };
  if (["Slatts", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "facexscars";
    _found = true;
  };
    if (["G4rrus", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "customflashlights";
    _found = true;
  };
  if ((["teriyaki", _AUTHOR] call BIS_fnc_inString || ["Dragonkeeper", _AUTHOR] call BIS_fnc_inString || ["TRYK_", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "tryk";
    _found = true;
  };
  if ((["zabb", _AUTHOR] call BIS_fnc_inString || ["Xmosmos", _AUTHOR] call BIS_fnc_inString || ["TAC_", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "tacvests";
    _found = true;
  };
  if ((["VanSchmoozin", _AUTHOR] call BIS_fnc_inString || ["Bacon", _AUTHOR] call BIS_fnc_inString || ["Alpine_", _NAME] call BIS_fnc_inString || ["DTS_", _NAME] call BIS_fnc_inString || ["_Massif", _NAME] call BIS_fnc_inString || ["_opscore", _NAME] call BIS_fnc_inString || ["VSM_", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "vsm";
    _found = true;
  };
  if (["da12thMonkey", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "rksl";
    _found = true;
  };
  if ((["ACRE2Team", _AUTHOR] call BIS_fnc_inString || ["ACRE_", _NAME] call BIS_fnc_inString) && _found == false) then {
    _modName = "acre";
    _found = true;
  };
    if (["Jaffa", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "nutresource";
    _found = true;
  };
  if ((["Frisia", _AUTHOR] call BIS_fnc_inString || ["Free World Armoury", _AUTHOR] call BIS_fnc_inString) && _found == false) then {
    _modName = "nutresource3party";
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
  if (["Adacas", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "militarygearpack";
    _found = true;
  };
  if (["Rainman", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "rmswatuniform";
    _found = true;
  };
  if (["Exocet", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "solidcoloruniforms";
    _found = true;
  };
  if (["Exocet", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "solidcoloruniforms";
    _found = true;
  };
  if (["Drongo", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "drongosartillery";
    _found = true;
  };
  if (["camel", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "projectbjc";
    _found = true;
  };
  if (["kat_", _NAME] call BIS_fnc_inString && _found == false) then {
    _modName = "katadvancedmedical";
    _found = true;
  };
  if (["SKEENBREEN", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "sbsvsmretexture";
    _found = true;
  };
  if (["BW-", _AUTHOR] call BIS_fnc_inString && _found == false) then {
    _modName = "bwmod";
    _found = true;
  };
  if ((["Rotators Collective", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "westernsahara";
    _found = true;
  };
  if ((["Enoch", _DLC] call BIS_fnc_inString || ["Contact", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "contact";
    _found = true;
  };
  if ((["Kart", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "karts";
    _found = true;
  };
  if ((["Mark", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "marksman";
    _found = true;
  };
  if ((["Tank", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "tanks";
    _found = true;
  };
  if ((["Expansion", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "apex";
    _found = true;
  };
  if ((["AoW", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "artofwar";
    _found = true;
  };
  if ((["Heli", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "helicopters";
    _found = true;
  };
  if ((["Orange", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modName = "lawsofwar";
    _found = true;
  };
  if ((["Bravo Zero One Studios", _AUTHOR] call BIS_fnc_inString || ["Jets", _DLC] call BIS_fnc_inString) && _found == false) then {
    _modname = "jets";
    _found = true;
  };
  if ((["Bohemia Interactive", _AUTHOR] call BIS_fnc_inString || _NAME == "None") && _found == false) then {
    _modName = "vanilla";
    _found = true;
  };

  // Not found, either object is a placeholder null class, author is not provided or is not supported yet
  if (_found == false && _AUTHOR != "") then {
     _modName = _AUTHOR;
     _found = true;
  };
  if (_found == false) then {
    throw format ["[ERROR] CFG_To_JSON.sqf - Author entry for class %1 is FALSE", _NAME];
  };

  _modName
};

// START: Iterate over config files
private _allClassConfigs = [];
{
  // Type of config (e.g. weapons, magazines, etc)
  private _CONFIGTYPE = _x;
  private _CONFIGLIST = _y;
  
  // Iterate over configs in type
  private _currentClassConfigs = [];
  {
    // Save config details
    private _CURRENTCONFIGPATH = _x;
    private _CONFIGNAME = configName _CURRENTCONFIGPATH; // e.g. [classname of config]
    diag_log format ["[INFO] CFG_To_JSON.sqf - Getting type for %1", _CURRENTCONFIGPATH];
    private _TYPE = [_CONFIGNAME, (_CONFIGNAME call BIS_fnc_itemType)] call getType;
    // Hacky way around checking if it's a config we actually want to extract or not
    if (typeName (_TYPE select 0) == "BOOL") then {
      diag_log format ["[INFO] CFG_To_JSON.sqf - Skipping config file %1, not an arsenal object", _CURRENTCONFIGPATH];
      continue;
    };

    private _currentConfig = call CBA_fnc_createNamespace;
    _currentConfig setVariable ["class", _CONFIGNAME];
    _currentConfig setVariable ["type", _TYPE select 0];
    _currentConfig setVariable ["subtype", _TYPE select 1];

    // Add config keys and values
    private _CONFIGKEYS = configProperties [_CURRENTCONFIGPATH, "true", true];

    if (count _CONFIGKEYS > 0) then {
      {
        private _currentConfigKey = _x;
        diag_log format ["[DEBUG] CFG_To_JSON.sqf - Reading config property %1", _currentConfigKey];
        // Parse value
        private _currentValue = "";
        if (isText _currentConfigKey) then {
          // Escape all backslashes and double quotes
          _currentValue = [[getText (_currentConfigKey), "\", "\\"] call CBA_fnc_replace, '"', '\"'] call CBA_fnc_replace;
        };
        if (isNumber _currentConfigKey) then {
          _currentValue = getNumber (_currentConfigKey);
        };
        if (isArray _currentConfigKey) then {
          _currentValue = getArray (_currentConfigKey) apply {_currentConfigKey};
        };

        // Add to map
        _currentConfig setVariable [configName _x, _currentValue];
      } forEach _CONFIGKEYS;

      // Calculate likely mod from DLC and Author values
      private _modName = [
        _CONFIGNAME,
        _currentConfig getVariable "dlc",
        _currentConfig getVariable "author"
      ] call getModName;
      _currentConfig setVariable ["mod", _modName];

      // Create formatted JSON string for the entire config
      diag_log format ["[INFO] CFG_To_JSON.sqf - Finished parsing config file %1, encoding to JSON...", _CONFIGNAME];
      _currentClassConfigs pushBack ([_currentConfig] call CBA_fnc_encodeJSON);
    } else {
      // Failed to retrieve config properties
      throw format ["[ERROR] CFG_To_JSON.sqf - FAILED to retrieve config properties for %1", _CONFIGNAME];
    };

  } forEach _CONFIGLIST;

  // Concatenate all collected objects and add to json array
  diag_log format ["[DEBUG] CFG_To_JSON.sqf - Appending all %1 configs in %2 type to return array", count _currentClassConfigs, _CONFIGTYPE];
  _allClassConfigs append _currentClassConfigs;

} forEach _CONFIGS;

// Copy to clipboard and finish
diag_log "[DEBUG] CFG_To_JSON.sqf - Done! Printing out to clipboard";
copyToClipboard str _allClassConfigs;
_allClassConfigs
