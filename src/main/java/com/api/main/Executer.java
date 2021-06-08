package com.api.main;

import java.net.UnknownHostException;
import java.util.ArrayList;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

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
    public String classes(
        @PathVariable(required = false, value = "mod") String mod,
        @RequestParam(required = false, value = "type") String type
    ) throws Exception {
        // Verify params
        if (!Config.getMods().contains(mod)) {
            return "Unidentified mod. Available values are " + Config.getTypes().toString();
        }
        if (!Config.getTypes().contains(type)) {
            return "Unidentified object type. Available values are " + Config.getTypes().toString();
        }

        if (mod.isEmpty()) {
            ArrayList<Document> dbContents = new ArrayList<Document>();
            for (String collectionName : DATABASE.listCollectionNames()) {
                MongoCollection<Document> currentCollection = getCollection(collectionName);
                dbContents.add(currentCollection.find().first());
            }

            return String.valueOf(dbContents);
        } else {
            MongoCollection<Document> collection = getCollection("data." + mod);
            return String.valueOf(collection.find());
        }
    }

}
