package com.api.main;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.UnknownHostException;
import java.nio.file.Files;
import java.util.*;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mongodb.BasicDBObject;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.*;
import com.mongodb.client.model.Indexes;

import org.bson.Document;
import org.json.simple.*;
import org.json.simple.parser.*;

public class Updater {

    public static void main(String[] args) throws UnknownHostException, IOException, FileNotFoundException, ParseException {

        // Setup Json parser and Mongodb
        final JSONParser PARSER = new JSONParser();
        final MongoClient MONGO_CLIENT = new MongoClient(new MongoClientURI("mongodb://localhost:27017"));
        final MongoDatabase DATABASE = MONGO_CLIENT.getDatabase("arma-api");

        // Backup and reset db
        MongoIterable<String> collections = DATABASE.listCollectionNames();
        for (String collectionName : collections) {
            final String backupCollectionName = collectionName + ".BACKUP";
            System.out.println("[INFO] Backing up and resetting " + collectionName + " to " + backupCollectionName);

            // Delete existing backup if it exists
            DATABASE.getCollection(backupCollectionName).drop();

            // Pipeline
            ArrayList<BasicDBObject> pipelineOps = new ArrayList<BasicDBObject>(
                Arrays.asList(new BasicDBObject("$out", backupCollectionName))
            );

            // Copy contents of collection to backup
            MongoCollection<Document> collection = DATABASE.getCollection(collectionName);
            collection.aggregate(pipelineOps);

            // Delete contents of prod collection
            collection.deleteMany(new Document());
            collection.dropIndexes();
        }

        Files.list(new File(System.getProperty("user.dir") + "/data").toPath()).forEach(path -> {
            System.out.println("[INFO] Parsing " + path);
            try {
                // Read JSON file
                final JSONArray jsonData = (JSONArray) PARSER.parse(new FileReader(path.toString()));
                jsonData.forEach(configStr -> {
                    try {
                        // Parse json string
                        final JSONObject configObj = (JSONObject) configStr;

                        // Create mongo document
                        final Document configDoc = new Document(
                            new ObjectMapper().readValue(configObj.toJSONString(), HashMap.class)
                        );

                        // Calculate target collection based off mod and append
                        DATABASE.getCollection("data." + configObj.get("mod").toString())
                            .insertOne(configDoc);
                    } catch (JsonProcessingException e) {
                        System.out.println("[WARNING] Could not create mongo document from config object:\n" + configStr);
                        e.printStackTrace();
                    }
                });
            } catch (FileNotFoundException | ParseException e) {
                System.out.println("[WARNING] Could not find or read " + path);
                e.printStackTrace();
            } catch (IOException e) {
                System.out.println("[WARNING] Could not parse " + path + " to a JSON Array");
                e.printStackTrace();
            }
            System.out.println("[SUCCESS] " + path + " successfully parsed and added to mongo db!");
        });

        // Update indices
        System.out.println("[INFO] Updating indices for all collections...");
        collections = DATABASE.listCollectionNames();
        for (String collectionName : collections) {
            DATABASE.getCollection(collectionName).createIndex(Indexes.text());
        }

        // Close connection
        System.out.println("[SUCCESS] Parsed and Uploaded all JSON files! Closing connection...");
        MONGO_CLIENT.close();
    }

}