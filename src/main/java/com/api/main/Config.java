package com.api.main;

import java.util.*;

/**
 * Configuration class that holds general static and connection information such as the permitted mods and types
 */
public abstract class Config {
    private static final ArrayList<String> MODS = new ArrayList<String>(Arrays.asList(
        "vanilla", "ace", "3cb", "rhs", "niarms", "tacvests",
        "vsm", "rksl", "acre", "projectopfor", "immersioncigs"
    ));

    private static final ArrayList<String> TYPES = new ArrayList<String>(Arrays.asList(
        "Primaries", "Secondaries", "Launchers", "Throwables", "Explosives", "Muzzles",
        "Pointers", "Optics", "Bipods", "Tools", "Terminals", "Maps", "GPSs", "Radios",
        "Compasses", "Watches", "Facewear", "Headgear", "Goggles", "Binoculars",
        "Magazines", "Uniforms", "Vests", "Backpacks"
    ));

    public static ArrayList<String> getMods() {
        return MODS;
    }

    public static ArrayList<String> getTypes() {
        return TYPES;
    }
}
