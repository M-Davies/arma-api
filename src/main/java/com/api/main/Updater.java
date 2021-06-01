package com.example.main;

import java.util.*;
import java.io.*;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import org.bson.Document;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;
import java.net.UnknownHostException;
import java.nio.file.Files;
import java.nio.file.Paths;
import org.json.simple.parser.JSONParser;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.ParseException;

public class Updater {

    public static void main(String[] args) throws UnknownHostException, IOException {
        // Setup Json parser and Mongodb
        JSONParser PARSER = new JSONParser();
        MongoClient MONGO_CLIENT = new MongoClient(new MongoClientURI("mongodb://localhost:27017"));
        MongoDatabase DATABASE = MONGO_CLIENT.getDatabase("arma-api");

        // Iterate over mod Json data files
        Files.list(new File(System.getProperty("user.dir") + "/data").toPath()).forEach(path -> {
            // Set corresponding mongo db collection
            String[] splitPath = path.toString().split("/");
            String filename = splitPath[splitPath.length - 1];
            MongoCollection<Document> collection = DATABASE.getCollection("data." + filename);

            try {
                // Read mod JSON file
                FileReader reader = new FileReader(path.toString());
                Object obj = PARSER.parse(reader);
                JSONArray modClassList = (JSONArray) obj;

                // Add to mongo
                collection.insertOne(Document.parse(modClassList.toString()));
            } catch (FileNotFoundException | ParseException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        });

        // Close connection
        MONGO_CLIENT.close();
    }

}