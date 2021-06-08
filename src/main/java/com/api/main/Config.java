package com.api.main;

import java.util.*;

public abstract class Config {
    private static ArrayList<String> MODS = new ArrayList<String>(Arrays.asList(
        "vanilla", "ace"
    ));

    private static ArrayList<String> TYPES = new ArrayList<String>(Arrays.asList(
        "Weapons", "Throwables", "Explosives", "Magazines",
        "Items", "Facewear", "Headgear", "NVG", "Binoculars",
        "Uniforms", "Rigs", "Backpacks"
    ));

    public static ArrayList<String> getMods() {
        return MODS;
    }

    public static ArrayList<String> getTypes() {
        return TYPES;
    }
}
