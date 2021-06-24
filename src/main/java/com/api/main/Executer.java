package com.api.main;

import java.net.UnknownHostException;
import java.util.*;
import java.util.stream.Collectors;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;

import org.bson.Document;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Executer {
    private static MongoDatabase DATABASE;
    private static ArrayList<Character> SPECIAL_MONGO_CHARS = new ArrayList<Character>(Arrays.asList('\'', '\"', '\\', ';', '{', '}', '$'));

    public static void main(String[] args) throws UnknownHostException {
        MongoClient MONGO_CLIENT = new MongoClient(new MongoClientURI("mongodb://localhost:27017"));
        DATABASE = MONGO_CLIENT.getDatabase("arma-api");
        SpringApplication.run(Executer.class, args);
    }

    private MongoCollection<Document> getCollection(String collectionName) throws Exception {
        ArrayList<String> collections = new ArrayList<String>();
        DATABASE.listCollectionNames().into(collections);
        if (collections.contains(collectionName) == true) {
            return DATABASE.getCollection(collectionName);
        } else {
            throw new Exception(collectionName + " is an unknown class type");
        }
    }

    private String escapeUserInput(String unfilteredInput) {
        String filteredInput = "";
        for (int i = 0; i < unfilteredInput.length(); i++) {
            char currentCharecter = unfilteredInput.charAt(i);
            if (!SPECIAL_MONGO_CHARS.contains(currentCharecter)) {
                filteredInput += currentCharecter;
            }
        }
        return filteredInput;
    }

    @GetMapping(value = {"/classes", "/classes/{mod}"})
    public String classes (
        @PathVariable(required = false, value = "mod") String mod,
        @RequestParam(required = false, value = "type") String type
    ) throws Exception {
        // Check user input
        final String filteredMod = mod == "" || mod == null ? "" : escapeUserInput(mod);
        final String filteredType = type == "" || type == null ? "" : escapeUserInput(type);

        // Verify params
        if (!Config.getMods().contains(filteredMod) && filteredMod != "") {
            throw new Exception("Unidentified mod. Available values are " + Config.getMods().toString());
        }
        if (!Config.getTypes().contains(filteredType) && filteredType != "") {
            throw new Exception("Unidentified object type. Available values are " + Config.getTypes().toString());
        }

        // Filter db by keywords or return all
        ArrayList<Document> dbContents = new ArrayList<Document>();
        for (String modName : DATABASE.listCollectionNames()) {
            final String parsedModName = "data." + filteredMod;

            // Filter by mod
            if (modName.equals(parsedModName)) {
                MongoCollection<Document> modContents = getCollection(modName);
                if (filteredType.isEmpty()) {
                    modContents.find().into(dbContents);
                } else {
                    modContents.find(Filters.eq("type", filteredType)).into(dbContents);
                }

                // Break so we only return a singular mod spec
                break;
            } else if (filteredMod.isEmpty()) {
                // Get all mods
                MongoCollection<Document> modContents = getCollection(modName);
                if (filteredType.isEmpty()) {
                    modContents.find().into(dbContents);
                } else {
                    modContents.find(Filters.eq("type", filteredType)).into(dbContents);
                }
            }
        }

        // Prettify and respond
        return String.valueOf(dbContents
            .stream()
            .distinct()
            .map(typeDoc -> typeDoc.toJson())
            .sorted()
            .collect(Collectors.toList())
        );
    }

    @GetMapping(value = {"/classes/search/{term}"})
    public String className (
        @PathVariable(required = true, value = "term") String term
    ) throws Exception {
        // Escape user input
        final String filteredTerm = escapeUserInput(term);

        // Match using Bson filter
        ArrayList<Document> matchedClasses = new ArrayList<Document>();
        for (String modName : DATABASE.listCollectionNames()) {
            ArrayList<Document> filteredContents = new ArrayList<Document>();
            try {
                getCollection(modName).find(
                    Filters.eq("count", Long.parseLong(filteredTerm))
                ).into(filteredContents);
            } catch (NumberFormatException e) {
                getCollection(modName).find(Filters.text(filteredTerm)).into(filteredContents);
            }

            // Add to final doc if match is found
            if (filteredContents != null) {
                matchedClasses.addAll(filteredContents);
            }
        }

        return String.valueOf(matchedClasses
            .stream()
            .distinct()
            .map(typeDoc -> typeDoc.toJson())
            .sorted()
            .collect(Collectors.toList())
        );

    }

}
