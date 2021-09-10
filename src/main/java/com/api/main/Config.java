package com.api.main;

import java.util.*;
import com.mongodb.MongoClientURI;
import io.github.cdimascio.dotenv.Dotenv;

/**
 * Configuration class that holds general static and connection information such as the permitted mods and types, some of it based on the user's .env file.
 */
public abstract class Config {

    public Config() {}

    private static final Dotenv dotenv = Dotenv.load();

    private static final MongoClientURI MONGO_URI = dotenv.get("MONGO_URI").isEmpty() != false ? new MongoClientURI(dotenv.get("MONGO_URI")) : new MongoClientURI("mongodb://localhost:27017");

    private static final String MONGO_DATABASE = dotenv.get("MONGO_DATABASE").isEmpty() != false ? dotenv.get("MONGO_DATABASE").toString() : "arma-api";

    private static final String LOGFILE_PATH = dotenv.get("LOGFILE_PATH").isEmpty() != false ? dotenv.get("LOGFILE_PATH").toString() : "/tmp/arma-api.log";

    private static final ArrayList<String> MODS = dotenv.get("SUPPORTED_MODS").isEmpty() != false ?
        new ArrayList<String>(Arrays.asList(dotenv.get("SUPPORTED_MODS"))) :
        new ArrayList<String>(Arrays.asList(
            "vanilla", "ace", "3cb", "rhs", "niarms", "tacvests", "tryk",
            "vsm", "rksl", "acre", "projectopfor", "immersioncigs"
        ));

    private static final ArrayList<String> TYPES = new ArrayList<String>(Arrays.asList(
        "Primaries", "Secondaries", "Launchers", "Throwables", "Explosives", "Muzzles",
        "Pointers", "Optics", "Bipods", "Tools", "Terminals", "Maps", "GPSs", "Radios",
        "Compasses", "Watches", "Facewear", "Headgear", "Goggles", "Binoculars",
        "Magazines", "Uniforms", "Vests", "Backpacks"
    ));

    private final static ArrayList<Character> SPECIAL_MONGO_CHARS = new ArrayList<Character>(Arrays.asList('\'', '\"', '\\', ';', '{', '}', '$'));

    public static MongoClientURI getMongoUri() {
        return MONGO_URI;
    }

    public static String getMongoDatabaseName() {
        return MONGO_DATABASE;
    }

    public static String getLogfilePath() {
        return LOGFILE_PATH;
    }

    public static ArrayList<String> getMods() {
        return MODS;
    }

    public static ArrayList<String> getTypes() {
        return TYPES;
    }

    public static ArrayList<Character> getSpecialChars() {
        return SPECIAL_MONGO_CHARS;
    }
}
