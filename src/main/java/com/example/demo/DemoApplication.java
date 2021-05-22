package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBObject;
import com.mongodb.DBCursor;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import java.net.UnknownHostException;

@SpringBootApplication
@RestController
public class DemoApplication {
	private static DB database;
	private DBCollection collection;


	public static void main(String[] args) throws UnknownHostException {
		MongoClient mongoClient = new MongoClient(new MongoClientURI("mongodb://localhost:27017"));
		database = mongoClient.getDB("arma-api");
		SpringApplication.run(DemoApplication.class, args);
	}

	@GetMapping("/hello")
	public String hello(
			@RequestParam(value = "name", defaultValue = "World")
					String name
	) {
		return String.format("Hello %s!", name);
	}

	@GetMapping("/ace")
	public String ace() {
		collection = collection = database.getCollection("data.ace");
		return String.valueOf(collection.count());
	}

}
