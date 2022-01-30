package com.api.main;

import java.util.ArrayList;
import java.util.Arrays;

import com.mongodb.MongoClientURI;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration class that holds general static and connection information such as the permitted mods and types, some of it based on the user's config file.
 */
@Configuration
public class Config {

    @Value("${config.HOST:http://localhost:8080}")
    private String host;

    @Value("${config.MONGO_URI:mongodb://localhost:27017}")
    private String mongoUri;

    @Value("${config.MONGO_DATABASE:arma-api}")
    private String mongoDatabase;

    @Value("${config.LOGFILE_PATH:/tmp/arma-api.log}")
    private String logfilePath;

    @Value("${config.SUPPORTED_MODS:vanilla,ace,3cb,rhs,niarms,tacvests,tryk,vsm,rksl,acre,projectopfor,immersioncigs}")
    private String supportedMods;

    @Value("${config.ARMA_PATH}")
    private String armaPath;

    private static final ArrayList<String> TYPES = new ArrayList<String>(Arrays.asList(
        "Primaries", "Secondaries", "Launchers", "Throwables", "Explosives", "Muzzles",
        "Pointers", "Optics", "Bipods", "Tools", "Terminals", "Maps", "GPSs", "Radios",
        "Compasses", "Watches", "Facewear", "Headgear", "Goggles", "Binoculars",
        "Magazines", "Uniforms", "Vests", "Backpacks"
    ));

    private final static ArrayList<Character> SPECIAL_MONGO_CHARS = new ArrayList<Character>(Arrays.asList('\'', '\"', '\\', ';', '{', '}', '$'));

    public String getHost() {
        return host;
    }

    public MongoClientURI getMongoUri() {
        return new MongoClientURI(mongoUri);
    }

    public String getMongoDatabaseName() {
        return mongoDatabase;
    }

    public String getLogfilePath() {
        return logfilePath;
    }

    public ArrayList<String> getMods() {
        return new ArrayList<String>(Arrays.asList(supportedMods.split(",")));
    }

    public String getArmaPath() {
        return armaPath;
    }

    public ArrayList<String> getTypes() {
        return TYPES;
    }

    public ArrayList<Character> getSpecialChars() {
        return SPECIAL_MONGO_CHARS;
    }
}
