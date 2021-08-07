//  This file converts the contents of the CfgWeapons, CfgMagazines and CfgGlasses config file to a JSON string

private _jsonClasses = "";

// Extract weapon values by scope param
private _configs = createHashMapFromArray [
  ["weapons", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgWeapons")],
  ["magazines", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgMagazines")],
  ["glasses", "getNumber (_x >> 'scope') isEqualTo 2" configClasses (configFile >> "CfgGlasses")]
];

{
  private _configText;
  if (_x == "weapons") then {
    _configText = _y apply {
      // Calculate weapon type
      private _type = "";
      private _subtype = "";
      if (getNumber (_x >> "type") == 1) then {
        _type = "Weapon";
        _subtype = "Primary";
      } else if (getNumber (_x >> "type") == 2) then {
        _type = "Weapon";
        _subtype = "Secondary";
      } else if (getNumber (_x >> "type") == 4) then {
        _type = "Weapon";
        _subtype = "Launcher";
      } else if (getNumber (_x >> "type") >= 605) then {
        _type = "Headgear";
      } else if (getNumber (_x >> "type") <= 701) then {
        _type = "Vest";
      } else if (getNumber (_x >> "type") >= 801) then {
        _type = "Uniform";
      } else {
        throw "ERROR: Unknown Type id = " + getNumber (_x >> "type");
      }

      // Format each hit to a JSON object and strip out chars that interfere with JSON parsing
      format [
        '  {%1    "class":"%2",%3    "displayName":"%4",%5    "description":"%6",%7    "image":"%8",%9    "magazines":%10,%11    "type":"%12",%13    "subtype":"%14",%15    "magwell":%16%17  }',
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
        getArray (_x >> "magazineWell") apply {_x},
        endl
      ]};
  } else if (_x == "magazines") then {

  } else {

  }

  // Concatenate all objects and add closing/opening remarks
  private _joined = _configText joinString "," + endl;
  _jsonClasses = _jsonClasses + format ['"Weapons" : [%1  %2%3],', endl, _joined, endl];
} forEach _configs;

// Copy and return
_jsonClasses = format ["{%1  %2%3}", endl, _jsonClasses, endl];
copyToClipboard _jsonClasses;
_jsonClasses
