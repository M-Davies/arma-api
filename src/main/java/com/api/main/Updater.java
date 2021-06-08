package com.api.main;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.UnknownHostException;
import java.nio.file.Files;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

import org.bson.Document;
import org.json.simple.*;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class Updater {

    public static void main(String[] args) throws UnknownHostException, IOException, FileNotFoundException, ParseException {
        // Setup Json parser and Mongodb
        JSONParser PARSER = new JSONParser();
        MongoClient MONGO_CLIENT = new MongoClient(new MongoClientURI("mongodb://localhost:27017"));
        MongoDatabase DATABASE = MONGO_CLIENT.getDatabase("arma-api");

        // Iterate over mod Json data files
        Files.list(new File(System.getProperty("user.dir") + "/data").toPath()).forEach(path -> {
            System.out.println("[INFO] Parsing " + path);

            // Set corresponding mongo db collection
            String[] splitPath = path.toString().split("/");
            String filename = splitPath[splitPath.length - 1].replace(".json", "");
            String collectionName = "data." + filename;
            System.out.println("[INFO] Collection name will be " + collectionName);
            MongoCollection<Document> collection = DATABASE.getCollection(collectionName);

            try {
                // Read mod JSON file
                FileReader reader = new FileReader(path.toString());
                JSONObject jsonData = (JSONObject) PARSER.parse(reader);

                // Clear & update collection with new values
                collection.deleteMany(new Document());
                jsonData.keySet().forEach(typeName -> {
                    Document typeDocument = new Document(typeName.toString(), jsonData.get(typeName));
                    collection.insertOne(typeDocument);
                });
            } catch (FileNotFoundException | ParseException e) {
                System.out.println("[WARNING] Could not find or read " + path);
                e.printStackTrace();
            } catch (IOException e) {
                System.out.println("[WARNING] Could not parse " + path + " to a Object datatype");
                e.printStackTrace();
            }

            System.out.println("[SUCCESS] " + collectionName + " has been successfully parsed and added to mongo db");
        });

        // Close connection
        System.out.println("[SUCCESS] Parsed and Uploaded all JSON files! Closing connection...");
        MONGO_CLIENT.close();
    }

}