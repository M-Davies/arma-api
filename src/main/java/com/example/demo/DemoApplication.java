package com.example.demo;

import java.util.*;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.bson.Document;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;
import java.net.UnknownHostException;

@SpringBootApplication
@RestController
public class DemoApplication {
	private static MongoDatabase DATABASE;


	public static void main(String[] args) throws UnknownHostException {
		MongoClient MONGO_CLIENT = new MongoClient(new MongoClientURI("mongodb://localhost:27017"));
		DATABASE = MONGO_CLIENT.getDatabase("arma-api");
		SpringApplication.run(DemoApplication.class, args);
	}

	@GetMapping("/hello")
	public String hello(
			@RequestParam(value = "name", defaultValue = "World")
					String name
	) {
		return String.format("Hello %s!", name);
	}

	@GetMapping("/classes")
	public String classes() {
		ArrayList<Document> collectionContents = new ArrayList<Document>();
		DATABASE.listCollectionNames().forEach(collectionName -> {
			MongoCollection<Document> currentCollection = DATABASE.getCollection(collectionName);
			collectionContents.add(currentCollection.find());
		});

		return String.valueOf(collection.count());
	}

	@GetMapping("/classes/ace")
	public String ace() {
		private DBCollection collection = database.getCollection("data.ace");
		return String.valueOf(collection.count());
	}

}
