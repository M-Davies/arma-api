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

    @GetMapping("/hello")
    public String hello(@RequestParam(value = "name", defaultValue = "World") String name) {
        return String.format("Hello %s!", name);
    }

    @GetMapping(value = {"/classes", "/classes/{mod}"})
    public String classes (
        @PathVariable(required = false, value = "mod") String mod,
        @RequestParam(required = false, value = "type") String type
    ) throws Exception {
        // Verify params
        if (!Config.getMods().contains(mod) && (mod != null && mod != "")) {
            return "Unidentified mod. Available values are " + Config.getMods().toString();
        }
        if (!Config.getTypes().contains(type) && (type != null && type != "")) {
            return "Unidentified object type. Available values are " + Config.getTypes().toString();
        }

        // Filter db by keywords or return all
        ArrayList<Document> dbContents = new ArrayList<Document>();
        for (String modName : DATABASE.listCollectionNames()) {
            String parsedModName = "data." + mod;

            // Filter by mod
            if (modName.equals(parsedModName)) {
                MongoCollection<Document> modContents = getCollection(parsedModName);
                if (type == "" || type == null) {
                    modContents.find().into(dbContents);
                } else {
                    modContents.find(Filters.eq("type", type)).into(dbContents);
                }

                // Break so we only return a singular mod spec
                break;
            } else if (mod == "" || mod == null) {
                // Get all mods
                MongoCollection<Document> modContents = getCollection(modName);
                if (type == "" || type == null) {
                    modContents.find().into(dbContents);
                } else {
                    modContents.find(Filters.eq("type", type)).into(dbContents);
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

}
